{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # Canonical store for ICM memories: the compiled server from the icm-sync
  # flake, so the VPS and the clients always run the same code.
  api = inputs.icm-sync.packages.${pkgs.stdenv.hostPlatform.system}.api;

  dataDir = "/var/lib/icm-sync";
  backupDir = "/var/backups/icm-sync";
  port = 3998;
in
{
  # Rendered at activation from sops (see the template below). The token is
  # shared with every client, so it lives here and nowhere else.
  sops.secrets.icm_sync_token = {
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "icm-sync-api.service" ];
  };

  sops.templates."icm-sync-env" = {
    path = "/etc/icm-sync.env";
    mode = "0400";
    owner = "root";
    group = "root";
    content = ''
      ICM_SYNC_DB=${dataDir}/icm-sync.db
      ICM_SYNC_TOKEN=${config.sops.placeholder.icm_sync_token}
      PORT=${toString port}
    '';
  };

  services.nginx.virtualHosts."icm.arifinoid.web.id" = {
    serverName = "icm.arifinoid.web.id";
    forceSSL = true;
    enableACME = true;

    # The API is JSON/NDJSON only; there is nothing static to serve.
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      extraConfig = ''
        proxy_connect_timeout 30s;
        # A full snapshot is one NDJSON stream, so give slow uplink room.
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
      '';
    };
  };

  security.acme.certs."icm.arifinoid.web.id" = {
    email = "rohmadarifin007@gmail.com";
    domain = "icm.arifinoid.web.id";
  };

  # A static system user (not DynamicUser) because the store file and the
  # backups must keep a stable owner across restarts.
  users.users.icm-sync = {
    isSystemUser = true;
    group = "icm-sync";
    home = dataDir;
    description = "ICM sync API";
  };
  users.groups.icm-sync = { };

  systemd.services.icm-sync-api = {
    description = "ICM sync API (canonical memory store)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${api}/bin/icm-sync-api";
      EnvironmentFile = "/etc/icm-sync.env";
      Restart = "on-failure";
      RestartSec = 5;

      User = "icm-sync";
      Group = "icm-sync";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      ReadWritePaths = [
        dataDir
        backupDir
      ];
    };
  };

  # VACUUM INTO a timestamped copy once a day, keeping two weeks.
  systemd.services.icm-sync-backup = {
    description = "Dump the ICM sync canonical store";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${inputs.self}/nix/scripts/icm-sync-backup.sh ${api}/bin/icm-sync-api";
      User = "icm-sync";
      Group = "icm-sync";
      Environment = "PATH=/run/current-system/sw/bin";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [
        dataDir
        backupDir
      ];
    };
  };

  systemd.timers.icm-sync-backup = {
    description = "Daily ICM sync store backup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:15:00 UTC";
      RandomizedDelaySec = "15m";
      # Catch up after downtime instead of skipping the day.
      Persistent = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 icm-sync icm-sync -"
    "d ${backupDir} 0750 icm-sync icm-sync -"
  ];
}
