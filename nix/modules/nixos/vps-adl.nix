{ pkgs, ... }:
let
  # ADL is three independently deployed services. Each one is published to
  # releases/<id> by nix/scripts/deploy-adl.sh, which then flips `current`.
  # Nothing is built from a repo path in the flake, so the apps' .env files
  # never end up in /nix/store.
  apiRoot = "/srv/adl/api";
  webRoot = "/srv/adl/web";
  fileRoot = "/srv/adl/file-service";

  apiPort = 8000;
  webPort = 3002;
  filePort = 8081;

  # nginx drops parent add_header directives as soon as a location defines its
  # own, so every location that adds headers repeats these (gixy requires it).
  securityHeaders = ''
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';

  apiLocation = {
    proxyPass = "http://127.0.0.1:${toString apiPort}";
    extraConfig = ''
      proxy_connect_timeout 10s;
      proxy_send_timeout 120s;
      proxy_read_timeout 120s;
    '';
  };
in
{
  # One origin for the PWA, the API and the upload proxy. The FE is a real Next
  # server (next start), not a static export, so every non-/api request is
  # proxied to it.
  services.nginx.virtualHosts."adl.arifinoid.web.id" = {
    serverName = "adl.arifinoid.web.id";
    forceSSL = true;
    enableACME = true;

    # Avatar/activity uploads pass through the API to file-service; nginx's
    # 1m default would reject most phone photos before they reach Bun.
    extraConfig = securityHeaders + ''
      client_max_body_size 10m;
    '';

    # The API already namespaces everything under /api, so the prefix is
    # forwarded untouched (no trailing slash on proxyPass).
    locations."/api/" = apiLocation;

    # Swagger UI plus /swagger/json, which generate-api reads when building FE.
    locations."/swagger" = apiLocation;

    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString webPort}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_connect_timeout 10s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
      '';
    };
  };

  security.acme.certs."adl.arifinoid.web.id" = {
    email = "rohmadarifin007@gmail.com";
    domain = "adl.arifinoid.web.id";
  };

  # Three static users so each release has a stable owner and no service can
  # touch another service's files.
  users.users.adl = {
    isSystemUser = true;
    group = "adl";
    home = "/var/lib/adl";
  };
  users.groups.adl = { };

  users.users.adl-web = {
    isSystemUser = true;
    group = "adl-web";
    home = "/var/lib/adl-web";
  };
  users.groups.adl-web = { };

  users.users.adl-files = {
    isSystemUser = true;
    group = "adl-files";
    home = "/var/lib/adl-files";
  };
  users.groups.adl-files = { };

  # DATABASE_URL, JWT_SECRET and CORS_ORIGIN live in /etc/adl-api.env (root
  # 0400), created once by hand. They are deliberately not rendered from sops
  # or inlined here so they never enter the world-readable nix store.
  systemd.services.adl-api = {
    description = "ADL API (Bun/Elysia)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = [
      "${apiRoot}/current"
      "/etc/adl-api.env"
    ];
    environment = {
      NODE_ENV = "production";
      PORT = toString apiPort;
      HOME = "/var/lib/adl";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      WorkingDirectory = "${apiRoot}/current";
      ExecStart = "${pkgs.bun}/bin/bun src/index.ts";
      EnvironmentFile = "/etc/adl-api.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "adl";
      Group = "adl";
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
      ReadWritePaths = [ "/var/lib/adl" ];
    };
  };

  # Not wantedBy anything: the deploy script runs it before restarting the API,
  # so a failed schema push stops the deploy instead of serving a stale schema.
  systemd.services.adl-api-migrate = {
    description = "Apply the ADL Drizzle schema";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    unitConfig.ConditionPathExists = [
      "${apiRoot}/current"
      "/etc/adl-api.env"
    ];
    environment = {
      HOME = "/var/lib/adl";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${apiRoot}/current";
      ExecStart = "${pkgs.bun}/bin/bun x drizzle-kit push --force";
      EnvironmentFile = "/etc/adl-api.env";
      User = "adl";
      Group = "adl";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [ "/var/lib/adl" ];
    };
  };

  # Next.js SSR server. It needs write access to its own release tree because
  # next start writes image/ISR caches under .next/cache.
  systemd.services.adl-web = {
    description = "ADL PWA (Next.js)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "${webRoot}/current";
    environment = {
      NODE_ENV = "production";
      PORT = toString webPort;
      HOSTNAME = "127.0.0.1";
      NEXT_TELEMETRY_DISABLED = "1";
      HOME = "/var/lib/adl-web";
    };
    serviceConfig = {
      WorkingDirectory = "${webRoot}/current";
      ExecStart = "${pkgs.bun}/bin/bun run start";
      Restart = "on-failure";
      RestartSec = 5;

      User = "adl-web";
      Group = "adl-web";
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
        # Node's os.networkInterfaces() (called by next start) uses getifaddrs,
        # which needs netlink; without it the process dies at startup.
        "AF_NETLINK"
      ];
      ReadWritePaths = [
        webRoot
        "/var/lib/adl-web"
      ];
    };
  };

  # Rust utility that compresses uploads and publishes them to R2. The public
  # read URL is the Cloudflare Worker (cloudflare-workers repo, binding
  # MY_BUCKET -> file-service), exposed as R2_PUBLIC_URL in its env file.
  systemd.services.adl-file-service = {
    description = "ADL file service (Rust, R2 uploads)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = [
      "${fileRoot}/current/file-service"
      "/etc/adl-file-service.env"
    ];
    environment = {
      PORT = toString filePort;
      HOME = "/var/lib/adl-files";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      WorkingDirectory = "${fileRoot}/current";
      ExecStart = "${fileRoot}/current/file-service";
      EnvironmentFile = "/etc/adl-file-service.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "adl-files";
      Group = "adl-files";
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

  # Release directories written by nix/scripts/deploy-adl.sh over ssh.
  systemd.tmpfiles.rules = [
    "d /srv/adl 0755 root root -"
    "d ${apiRoot} 0755 root root -"
    "d ${apiRoot}/releases 0755 root root -"
    "d ${webRoot} 0755 root root -"
    "d ${webRoot}/releases 0755 root root -"
    "d ${fileRoot} 0755 root root -"
    "d ${fileRoot}/releases 0755 root root -"
    "d /var/lib/adl 0750 adl adl -"
    "d /var/lib/adl-web 0750 adl-web adl-web -"
    "d /var/lib/adl-files 0750 adl-files adl-files -"
  ];
}
