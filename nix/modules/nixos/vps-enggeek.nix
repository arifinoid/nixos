{ config, pkgs, ... }:
let
  # Deploy script (deploy/vps/deploy.sh in the eng-geek repo) uploads a release
  # to releases/<sha> and flips `current`. The Go binary serves /api/v1 and the
  # static export; nginx serves the static files from disk and proxies the API.
  root = "/srv/enggeek";

  # Not used for state yet (the database holds everything); kept so the service
  # has a home and a stable owner.
  data = "/var/lib/enggeek";

  apiPort = 8083;

  appHost = "enggeek.arifinoid.web.id";

  # nginx drops parent add_header directives as soon as a location defines its
  # own, so every location repeats these.
  securityHeaders = ''
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';

  # Peer auth over the local socket: the unit runs as the eng-geek OS user,
  # which ensureUsers maps to the same Postgres role. The database shares the
  # role name so ensureDBOwnership grants it outright (migrations then own
  # their own schema without a second role).
  databaseUrl = "postgres://eng-geek@/eng-geek?host=/var/run/postgresql";
in
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "eng-geek" ];
    ensureUsers = [
      {
        name = "eng-geek";
        ensureDBOwnership = true;
      }
    ];
  };

  users.users.eng-geek = {
    isSystemUser = true;
    group = "eng-geek";
    home = data;
  };
  users.groups.eng-geek = { };

  systemd.services.eng-geek = {
    description = "eng-geek API and static site (Go)";
    after = [
      "network.target"
      "postgresql.service"
    ];
    wants = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "${root}/current/server";
    environment = {
      PORT = toString apiPort;
      STATIC_DIR = "${root}/current/out";
      DATABASE_URL = databaseUrl;
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      ExecStart = "${root}/current/server";
      Restart = "on-failure";
      RestartSec = 5;

      User = "eng-geek";
      Group = "eng-geek";
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

  # Forward-only migrations + content seed, run by the deploy script before it
  # restarts the service. Not wantedBy anything: a failed migration must stop
  # the deploy instead of letting the API serve a half-migrated schema.
  systemd.services.eng-geek-migrate = {
    description = "eng-geek database migrations and content seed";
    after = [
      "postgresql.service"
      "network.target"
    ];
    wants = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "eng-geek";
      Group = "eng-geek";
      Environment = [
        "DATABASE_URL=${databaseUrl}"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
      ];
      ExecStart = pkgs.writeShellScript "eng-geek-migrate" ''
        set -euo pipefail

        ${pkgs.goose}/bin/goose \
          -dir "${root}/current/apps/api/db/migrations" \
          postgres "$DATABASE_URL" up

        ${root}/current/seed -content "${root}/current/apps/api/content/a1"
      '';
    };
  };

  services.nginx.virtualHosts.${appHost} = {
    serverName = appHost;
    forceSSL = true;
    enableACME = true;
    root = "${root}/current/out";

    extraConfig = securityHeaders;

    # Next `output: "export"` writes route/index.html, so a pretty URL maps to
    # a directory instead of a file. The Go server redirects / -> /id, so the
    # static vhost does the same.
    locations."= /".extraConfig = "return 307 /id;";
    locations."/" = {
      tryFiles = "$uri $uri/index.html =404";
    };

    locations."/_next/static/".extraConfig = ''
      ${securityHeaders}
      add_header Cache-Control "public, max-age=31536000, immutable" always;
    '';

    # Same-origin API: the generated client calls /api/v1/* (root-absolute).
    locations."/api/v1/" = {
      proxyPass = "http://127.0.0.1:${toString apiPort}";
      extraConfig = securityHeaders;
    };

    locations."/healthz" = {
      proxyPass = "http://127.0.0.1:${toString apiPort}";
      extraConfig = securityHeaders;
    };
  };

  security.acme.certs.${appHost} = {
    email = "rohmadarifin007@gmail.com";
    domain = appHost;
  };

  systemd.tmpfiles.rules = [
    "d ${root} 0755 root root -"
    "d ${root}/releases 0755 root root -"
    "d ${data} 0750 eng-geek eng-geek -"
  ];
}
