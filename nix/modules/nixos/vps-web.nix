{
  config,
  pkgs,
  inputs,
  ...
}:
let
  # CI (personal-web) uploads every commit to releases/<sha> and flips the
  # current symlink; nginx serves straight from disk.
  siteRoot = "/var/www/arifinoid";

  # v0.6.1: the connectors need safari15_5/ff117, which newer nixpkgs builds
  # no longer ship.
  curlImpersonate = pkgs.callPackage "${inputs.self}/nix/packages/curl-impersonate.nix" { };

  # Deploy job (job-hooker) uploads a Bun release to releases/<sha> and flips
  # `current`. The API runs from there; the SPA is served by nginx; restarting
  # jobhooker pins the new release. Rollback = re-point the symlink + restart.
  jobhookerRoot = "/srv/jobhooker";

  # Persistent state that must survive releases: PII key, render artifacts.
  # releases/<sha>/var is symlinked here by the deploy job.
  jobhookerData = "/var/lib/jobhooker";

  # nginx drops parent add_header directives as soon as a location defines its
  # own, so every location that adds headers repeats these (gixy rejects the
  # config otherwise).
  jobhookerSecurityHeaders = ''
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';
in
{
  # Rendered at activation from sops. The API and the migrate unit both read
  # this file; credentials never sit in a hand-edited /etc file or the store.
  sops.templates."jobhooker-env" = {
    path = "/etc/jobhooker.env";
    mode = "0400";
    content = ''
      DOMAIN=jobhooker.arifinoid.web.id
      API_TOKEN=${config.sops.placeholder.jobhooker_api_token}
      AUTH_DISABLED=0
      CORS_ORIGINS=https://jobhooker.arifinoid.web.id
      # Empty = connector disabled / LLM off. They are plain config on purpose:
      # a filled-in token should move to sops as jobhooker_greenhouse_tokens /
      # jobhooker_llm_api_key instead of being committed here.
      GREENHOUSE_TOKENS=
      ASHBY_ORGS=
      LEVER_SLUGS=
      SMARTRECRUITERS_IDS=BoschGroup
      BAYT_COUNTRIES=uae
      INDEED_COUNTRIES=
      LLM_OPT_IN=0
      LLM_API_KEY=
      LLM_BASE_URL=https://integrate.api.nvidia.com/v1
      LLM_MODEL=nvidia/nemotron-3-super-120b-a12b
      LLM_EMBED_ENABLED=0
      PII_KEY_FILE=var/pii-key
      PORT=3000
      RATE_LIMIT_MAX=120
      RATE_LIMIT_WINDOW_MS=60000
      DATABASE_URL=${config.sops.placeholder.jobhooker_database_url}
    '';
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    # Static site served straight from disk: no app server, no proxy hop.
    virtualHosts."arifinoid.web.id" = {
      serverName = "arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      root = "${siteRoot}/current";
      extraConfig = ''
        error_page 404 /404.html;
        add_header Cache-Control "no-cache" always;
      '';
      locations."/" = {
        # The static export writes route/index.html, so /explore resolves to
        # /explore/index.html instead of a directory listing.
        tryFiles = "$uri $uri/index.html =404";
      };
      locations."/_next/static/".extraConfig = ''
        add_header Cache-Control "public, max-age=31536000, immutable" always;
      '';
      locations."= /404.html".extraConfig = ''
        internal;
      '';
    };

    # SPA from the release + /api proxied to the native Bun service. This
    # replaces the old web container (nginx + /api proxy) and its extra hop.
    virtualHosts."jobhooker.arifinoid.web.id" = {
      serverName = "jobhooker.arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      root = "${jobhookerRoot}/current/apps/web/dist";

      extraConfig = jobhookerSecurityHeaders;

      locations."/" = {
        tryFiles = "$uri $uri/ /index.html";
      };

      locations."/api/" = {
        # Long calls (ingest walks every source, tailor calls the LLM) answer
        # in minutes; the proxy default of 60s would cut them off at 504.
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_connect_timeout 30s;
          proxy_send_timeout 600s;
          proxy_read_timeout 600s;
        '';
      };

      locations."~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$" = {
        extraConfig = jobhookerSecurityHeaders + ''
          add_header Cache-Control "public, max-age=31536000, immutable" always;
        '';
      };
    };
  };

  # Let's Encrypt via NixOS native ACME
  security.acme = {
    acceptTerms = true;
    certs."arifinoid.web.id" = {
      email = "rohmadarifin007@gmail.com";
      domain = "arifinoid.web.id";
    };

    certs."jobhooker.arifinoid.web.id" = {
      email = "rohmadarifin007@gmail.com";
      domain = "jobhooker.arifinoid.web.id";
    };
  };

  # A static system user (not DynamicUser) because the app needs a stable
  # owner for the PII key and render artifacts under ${jobhookerData}.
  users.users.jobhooker = {
    isSystemUser = true;
    group = "jobhooker";
    home = jobhookerData;
  };
  users.groups.jobhooker = { };

  # Native systemd service instead of the api container. Hardening gives it
  # container-like isolation without a container runtime.
  systemd.services.jobhooker = {
    description = "job-hooker API (Bun)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "${jobhookerRoot}/current";
    environment = {
      NODE_ENV = "production";
      PORT = "3000";
      HOME = jobhookerData;
      # Deploy job symlinks releases/<sha>/var -> ${jobhookerData}/var, so the
      # key lives outside the release tree and survives rollbacks.
      PII_KEY_FILE = "${jobhookerData}/var/pii-key";
      CURL_IMPERSONATE_DIR = "${curlImpersonate}/bin";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    serviceConfig = {
      WorkingDirectory = "${jobhookerRoot}/current";
      ExecStart = "${pkgs.bun}/bin/bun run apps/api/src/index.ts";
      # DATABASE_URL, API_TOKEN and connector/LLM settings live here, rendered
      # from sops at activation (see the jobhooker-env template above).
      EnvironmentFile = "/etc/jobhooker.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "jobhooker";
      Group = "jobhooker";
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
      ReadWritePaths = [ jobhookerData ];
    };
  };

  # Forward-only migrations, run by the deploy job before restarting the API.
  # Not wantedBy anything: a failed migration must stop the deploy instead of
  # letting the API serve a half-migrated schema.
  systemd.services.jobhooker-migrate = {
    description = "job-hooker database migrations";
    after = [ "network.target" ];
    unitConfig.ConditionPathExists = "${jobhookerRoot}/current";
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "${jobhookerRoot}/current";
      ExecStart = "${pkgs.bun}/bin/bun run packages/db/src/migrate.ts";
      EnvironmentFile = "/etc/jobhooker.env";
      User = "jobhooker";
      Group = "jobhooker";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [ jobhookerData ];
    };
  };

  # Release directories written by the deploy jobs over ssh.
  systemd.tmpfiles.rules = [
    "d ${siteRoot} 0755 root root -"
    "d ${siteRoot}/releases 0755 root root -"
    "d ${jobhookerRoot} 0755 root root -"
    "d ${jobhookerRoot}/releases 0755 root root -"
    "d ${jobhookerData} 0750 jobhooker jobhooker -"
    "d ${jobhookerData}/var 0750 jobhooker jobhooker -"
    "d ${jobhookerData}/var/artifacts 0750 jobhooker jobhooker -"
  ];

  environment.systemPackages = [ pkgs.rsync ];
}
