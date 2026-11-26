{ config, pkgs, ... }:
let
  # Deploy job (nata) uploads each commit to releases/<sha> and flips the
  # `current` symlink. nginx serves the static Next export straight from disk;
  # only the Rust API is a systemd service.
  nataRoot = "/srv/nata";

  apiPort = 3001;

  # nginx drops parent add_header directives as soon as a location defines its
  # own, so every location that adds headers repeats these.
  securityHeaders = ''
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';

  # Same-origin API, namespaced under /api so it can never shadow a static
  # route: the browser calls /api/dashboard while the app page lives at
  # /dashboard. The trailing slash on proxyPass makes nginx strip the prefix.
  apiLocation = {
    proxyPass = "http://127.0.0.1:${toString apiPort}";
    extraConfig = ''
      proxy_connect_timeout 10s;
      proxy_send_timeout 30s;
      proxy_read_timeout 30s;
    '';
  };

  apiPrefixLocation = apiLocation // {
    proxyPass = "http://127.0.0.1:${toString apiPort}/";
  };
in
{
  # Rendered at activation from sops: the API, the migration unit and the
  # alert job all read the same file, and nothing is hand-edited on the host.
  sops.templates."nata-env" = {
    path = "/etc/nata.env";
    mode = "0400";
    content = ''
      DATABASE_URL=${config.sops.placeholder.nata_database_url}
      MIGRATE_DATABASE_URL=${config.sops.placeholder.nata_migrate_database_url}
      NATA_APP_PASSWORD=${config.sops.placeholder.nata_app_password}
      JWT_SECRET=${config.sops.placeholder.nata_jwt_secret}
      PORT=${toString apiPort}
      RUST_LOG=info,tower_http=info
      JWT_TTL_SECONDS=86400
      EMAIL_FROM_NAME=Nata
      EMAIL_FROM=rohmadarifin007@gmail.com
      BREVO_API_KEY=${config.sops.placeholder.nata_brevo_api_key}
      APP_URL=https://nata.arifinoid.web.id
      EMAIL_PROVIDER=brevo
      OTP_TTL_SECONDS=300
      FONNTE_TOKEN=${config.sops.placeholder.nata_fonnte_token}
      WHATSAPP_PROVIDER=fonnte
    '';
  };

  services.nginx.virtualHosts."nata.arifinoid.web.id" = {
    serverName = "nata.arifinoid.web.id";
    forceSSL = true;
    enableACME = true;
    root = "${nataRoot}/current/out";

    extraConfig = securityHeaders;

    # Next `output: "export"` writes route/index.html, so a pretty URL maps to
    # a directory instead of a file.
    locations."/" = {
      tryFiles = "$uri $uri/index.html =404";
    };

    locations."/_next/static/".extraConfig = ''
      ${securityHeaders}
      add_header Cache-Control "public, max-age=31536000, immutable" always;
    '';

    # `= /me` stays exact: a prefix `/me` would also swallow `/members`.
    # /api/* -> 127.0.0.1:3001/* (prefix stripped). Everything else stays
    # static, so /dashboard/, /stock/ and /login/ can never collide with the
    # API routes of the same name.
    locations."/api/" = apiPrefixLocation;

    # Kept at the root for the deploy health check and uptime monitors.
    locations."/healthz" = apiLocation;
    locations."/api-docs/" = apiLocation;
  };

  security.acme.certs."nata.arifinoid.web.id" = {
    email = "rohmadarifin007@gmail.com";
    domain = "nata.arifinoid.web.id";
  };

  # Static system user because the service path is fixed; no writable state is
  # needed yet (Neon owns the database).
  users.users.nata = {
    isSystemUser = true;
    group = "nata";
    home = "/var/lib/nata";
  };
  users.groups.nata = { };

  systemd.services.nata-api = {
    description = "Nata API (Rust)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = [
      "${nataRoot}/current"
      "/etc/nata.env"
    ];
    environment = {
      PORT = toString apiPort;
      RUST_LOG = "info,tower_http=info";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      ExecStart = "${nataRoot}/current/bin/nata-api";
      WorkingDirectory = "${nataRoot}/current";
      # DATABASE_URL, JWT_SECRET and the rest live here, rendered from sops at
      # activation (see the nata-env template above).
      EnvironmentFile = "/etc/nata.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "nata";
      Group = "nata";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
    };
  };

  # Forward-only migrations, run by the deploy job before restarting the API.
  # Not wantedBy anything: a failed migration must stop the deploy instead of
  # letting the API serve a half-migrated schema. Migrations run as the owner
  # role; grant.sql then creates/refreshes the least-privilege runtime role.
  systemd.services.nata-migrate = {
    description = "Nata database migrations and grants";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = [
      "${nataRoot}/current"
      "/etc/nata.env"
    ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${nataRoot}/current";
      EnvironmentFile = "/etc/nata.env";
      Environment = "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt";
      ExecStart = pkgs.writeShellScript "nata-migrate" ''
        set -euo pipefail

        ${pkgs.sqlx-cli}/bin/sqlx migrate run \
          --source migrations \
          --database-url "$MIGRATE_DATABASE_URL"

        ${pkgs.postgresql_17}/bin/psql "$MIGRATE_DATABASE_URL" \
          -v ON_ERROR_STOP=1 \
          -v app_password="$NATA_APP_PASSWORD" \
          -f deploy/vps/grant.sql
      '';
      User = "nata";
      Group = "nata";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  # Daily alert job: fills and resolves alerts, then sends one digest per
  # tenant. It walks every tenant, so it uses the owner role; DATABASE_URL is
  # the RLS-bound runtime role and would only ever see one tenant. Delivery
  # state lives in the alerts table, so a failed send is retried on the next
  # run instead of being lost.
  systemd.services.nata-alert-job = {
    description = "Nata daily alert job";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = [
      "${nataRoot}/current"
      "/etc/nata.env"
    ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${nataRoot}/current";
      EnvironmentFile = "/etc/nata.env";
      Environment = "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt";
      ExecStart = pkgs.writeShellScript "nata-alert-job" ''
        set -euo pipefail

        export DATABASE_URL="$MIGRATE_DATABASE_URL"
        exec ${nataRoot}/current/bin/alert_job
      '';
      User = "nata";
      Group = "nata";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  systemd.timers.nata-alert-job = {
    description = "Daily Nata alert job";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # 00:10 UTC is 07:10 WIB. The job compares expiry against the UTC date,
      # so running earlier would alert on yesterday's date.
      OnCalendar = "*-*-* 00:10:00 UTC";
      RandomizedDelaySec = "5m";
      # Catch up after downtime instead of skipping the day.
      Persistent = true;
    };
  };

  # Weekly backup drill. Neon keeps its own backup and PITR, but a dump nobody
  # has restored is a guess. The script dumps, restores into a throwaway copy
  # beside the source, compares the schema, the RLS policies, an exact row count
  # and every column's value, then drops the copy. It creates that scratch
  # database, so it runs as the owner role: MIGRATE_DATABASE_URL, not the
  # RLS-bound DATABASE_URL. Dumps stay on the VPS for 14 days.
  systemd.services.nata-backup-drill = {
    description = "Nata weekly backup drill";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    # A scheduled drill nobody watches is worse than none: it quietly becomes
    # the backup you trust. This runs on a non-zero exit, so a failure leaves a
    # line to find. There is no notification channel yet.
    onFailure = [ "nata-backup-drill-failure.service" ];
    unitConfig.ConditionPathExists = [
      "${nataRoot}/current"
      "/etc/nata.env"
    ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${nataRoot}/current";
      EnvironmentFile = "/etc/nata.env";
      Environment = "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt";
      ExecStart = pkgs.writeShellScript "nata-backup-drill" ''
        set -euo pipefail

        # pg_dump, pg_restore and psql, pinned to the server's major version.
        export PATH="${pkgs.postgresql_17}/bin:$PATH"

        exec ${nataRoot}/current/deploy/vps/backup.sh \
          --url "$MIGRATE_DATABASE_URL" \
          --keep --retain 14 \
          --output /var/lib/nata/backups
      '';
      User = "nata";
      Group = "nata";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      # The dump directory is the only thing the drill writes.
      ReadWritePaths = [ "/var/lib/nata/backups" ];
    };
  };

  # Appends one line per failed drill. systemd runs it through OnFailure, which
  # also catches a kill, not just a non-zero exit.
  systemd.services.nata-backup-drill-failure = {
    description = "Nata backup drill failure log";
    serviceConfig = {
      Type = "oneshot";
      User = "nata";
      Group = "nata";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ "/var/lib/nata" ];
      ExecStart = pkgs.writeShellScript "nata-backup-drill-failure" ''
        set -euo pipefail
        printf '%s backup drill failed\n' \
          "$(${pkgs.coreutils}/bin/date -u +%Y-%m-%dT%H:%M:%SZ)" \
          >> /var/lib/nata/backup-failures.log
      '';
    };
  };

  systemd.timers.nata-backup-drill = {
    description = "Weekly Nata backup drill";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Sunday 03:10 UTC is 10:10 WIB, well clear of the alert job at 00:10.
      OnCalendar = "Sun *-*-* 03:10:00 UTC";
      RandomizedDelaySec = "10m";
      # Catch up after downtime instead of skipping the week.
      Persistent = true;
    };
  };

  # Release directories written by the deploy job over ssh, and the drill's dump
  # directory.
  systemd.tmpfiles.rules = [
    "d ${nataRoot} 0755 root root -"
    "d ${nataRoot}/releases 0755 root root -"
    "d /var/lib/nata 0750 nata nata -"
    "d /var/lib/nata/backups 0750 nata nata -"
  ];
}
