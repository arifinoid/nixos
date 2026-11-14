{ pkgs, ... }:
let
  # Pinned source; deploy job syncs this to /srv/ask-api/current on the VPS.
  askApiRoot = "/srv/ask-api";

  # Persistent state that survives releases: docs dir for extra RAG documents.
  askApiData = "/var/lib/ask-api";

  # The interpreter AND the dependencies. The plain pkgs.python3 in the system
  # profile has no fastapi/uvicorn, so the old ExecStart died on import. Pinning
  # the env here also removes the need for a pip/venv step on the VPS.
  askApiPython = pkgs.python3.withPackages (
    ps: with ps; [
      fastapi
      uvicorn
      pydantic
      httpx
      python-dotenv
      pypdf
    ]
  );

  # nginx drops every parent add_header as soon as a location defines its own,
  # so the vhost's Cache-Control (see vps-web.nix) has to be repeated here.
  # gixy runs as part of the build and fails on a missing parent header.
  securityHeaders = ''
    add_header Cache-Control "no-cache" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  '';
in
{
  # Rendered at activation from sops. The service reads this file; credentials
  # never sit in a hand-edited /etc file or the store.
  sops.templates."ask-api-env" = {
    path = "/etc/ask-api.env";
    mode = "0400";
    # A settings change in this file must take effect on rebuild, not on the
    # next unrelated restart.
    restartUnits = [ "ask-api.service" ];
    content = ''
      # CORS origins allowed to call the API (comma-separated).
      ALLOWED_ORIGINS=https://arifinoid.web.id,https://www.arifinoid.web.id

      # Optional LLM generation. Leave both unset for retrieval-only mode
      # (~200 MiB RAM, no model overhead). Move a filled-in key to sops.
      LLM_BASE_URL=
      LLM_API_KEY=
      LLM_MODEL=llama3.2:1b

      # Directory containing extra documents (txt / md / pdf) for RAG.
      DOCS_DIR=${askApiData}/docs
    '';
  };

  # Nginx locations serving the FastAPI service under the main domain
  # (path-based, matching docs/DEPLOY.md of the backend repo).
  services.nginx.virtualHosts."arifinoid.web.id".locations."/health" = {
    proxyPass = "http://127.0.0.1:8080";
    extraConfig = securityHeaders;
  };

  services.nginx.virtualHosts."arifinoid.web.id".locations."/v1/" = {
    proxyPass = "http://127.0.0.1:8080";
    # recommendedProxySettings (vps-web.nix) already emits Host, X-Real-IP,
    # X-Forwarded-For and X-Forwarded-Proto for every proxy location. Adding
    # proxy_set_header here would duplicate those, so only add_header lives
    # here.
    extraConfig = securityHeaders;
  };

  # The ask panel cites uploaded documents as /docs/<name>; serve them from the
  # same directory the service indexes. autoindex stays off, so a file is only
  # reachable by its exact name.
  services.nginx.virtualHosts."arifinoid.web.id".locations."/docs/" = {
    alias = "${askApiData}/docs/";
    extraConfig = securityHeaders;
  };

  # Static system user (not DynamicUser) because it owns the docs directory.
  users.users.ask-api = {
    isSystemUser = true;
    group = "ask-api";
    home = askApiData;
  };
  users.groups.ask-api = { };

  # nginx serves /docs/ straight from the service's 0750 docs directory, so it
  # joins the group instead of the directory being widened to world-readable.
  users.users.nginx.extraGroups = [ "ask-api" ];

  # Native systemd service instead of a container. Hardening gives it
  # container-like isolation without a container runtime.
  systemd.services.ask-api = {
    description = "ask panel FastAPI service (arifinoid.web.id)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.ConditionPathExists = "${askApiRoot}/current";
    environment = {
      HOME = askApiData;
      PYTHONUNBUFFERED = "1";
      # /srv is read-only for the service; don't try to cache bytecode there.
      PYTHONDONTWRITEBYTECODE = "1";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
      SSL_CERT_DIR = "/etc/ssl/certs";
    };
    serviceConfig = {
      WorkingDirectory = "${askApiRoot}/current";
      # LLM_API_KEY and CORS settings live here, rendered from sops at
      # activation (see the ask-api-env template above).
      EnvironmentFile = "/etc/ask-api.env";
      ExecStart = "${askApiPython}/bin/uvicorn main:app --host 127.0.0.1 --port 8080";
      Restart = "on-failure";
      RestartSec = 5;

      User = "ask-api";
      Group = "ask-api";
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
      ReadWritePaths = [ askApiData ];
    };
  };

  # Release directories written by the deploy job over ssh.
  systemd.tmpfiles.rules = [
    "d ${askApiRoot} 0755 root root -"
    "d ${askApiRoot}/releases 0755 root root -"
    "d ${askApiData} 0750 ask-api ask-api -"
    "d ${askApiData}/docs 0750 ask-api ask-api -"
  ];
}
