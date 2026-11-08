{ pkgs, ... }:
let
  # Deploy job (takar) uploads each commit to releases/<sha> and flips the
  # `current` symlink. nginx serves the static Next export straight from disk;
  # only the Rust API is a systemd service.
  takarRoot = "/srv/takar";

  apiPort = 3001;

  # nginx drops parent add_header directives as soon as a location defines its
  # own, so every location that adds headers repeats these.
  securityHeaders = ''
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';

  # Same-origin API: the browser talks to https://takar.arifinoid.web.id and
  # nginx forwards these prefixes to the loopback service, so the hardcoded
  # CORS allow-list (localhost + Tauri) never matters in production.
  apiLocation = {
    proxyPass = "http://127.0.0.1:${toString apiPort}";
    extraConfig = ''
      proxy_connect_timeout 10s;
      proxy_send_timeout 30s;
      proxy_read_timeout 30s;
    '';
  };
in
{
  services.nginx.virtualHosts."takar.arifinoid.web.id" = {
    serverName = "takar.arifinoid.web.id";
    forceSSL = true;
    enableACME = true;
    root = "${takarRoot}/current/out";

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
    locations."= /me" = apiLocation;
    locations."/healthz" = apiLocation;
    locations."/api-docs/" = apiLocation;
    locations."/auth/" = apiLocation;
    locations."/members" = apiLocation;
    locations."/stock" = apiLocation;
    locations."/master" = apiLocation;
  };

  security.acme.certs."takar.arifinoid.web.id" = {
    email = "rohmadarifin007@gmail.com";
    domain = "takar.arifinoid.web.id";
  };

  # Static system user because the service path is fixed; no writable state is
  # needed yet (Neon owns the database).
  users.users.takar = {
    isSystemUser = true;
    group = "takar";
    home = "/var/lib/takar";
  };
  users.groups.takar = { };

  systemd.services.takar-api = {
    description = "Takar API (Rust)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = [
      "${takarRoot}/current"
      "/etc/takar.env"
    ];
    environment = {
      PORT = toString apiPort;
      RUST_LOG = "info,tower_http=info";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      ExecStart = "${takarRoot}/current/bin/takar-api";
      WorkingDirectory = "${takarRoot}/current";
      # DATABASE_URL, JWT_SECRET and the rest live here (0600 root); created
      # once by hand or rendered from sops later.
      EnvironmentFile = "/etc/takar.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "takar";
      Group = "takar";
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
  systemd.services.takar-migrate = {
    description = "Takar database migrations and grants";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = [
      "${takarRoot}/current"
      "/etc/takar.env"
    ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${takarRoot}/current";
      EnvironmentFile = "/etc/takar.env";
      Environment = "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt";
      ExecStart = pkgs.writeShellScript "takar-migrate" ''
        set -euo pipefail

        ${pkgs.sqlx-cli}/bin/sqlx migrate run \
          --source migrations \
          --database-url "$MIGRATE_DATABASE_URL"

        ${pkgs.postgresql_17}/bin/psql "$MIGRATE_DATABASE_URL" \
          -v ON_ERROR_STOP=1 \
          -v app_password="$TAKAR_APP_PASSWORD" \
          -f deploy/vps/grant.sql
      '';
      User = "takar";
      Group = "takar";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };

  # Release directories written by the deploy job over ssh.
  systemd.tmpfiles.rules = [
    "d ${takarRoot} 0755 root root -"
    "d ${takarRoot}/releases 0755 root root -"
    "d /var/lib/takar 0750 takar takar -"
  ];
}
