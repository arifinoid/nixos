{
  config,
  lib,
  osConfig,
  inputs,
  pkgs,
  ...
}:

let
  # The compiled client from the icm-sync flake: a standalone binary, so no bun
  # and no node_modules are needed at runtime.
  sync = inputs.icm-sync.packages.${pkgs.stdenv.hostPlatform.system}.sync;

  hostName = osConfig.networking.hostName or "unknown";
  envFile = "${config.home.homeDirectory}/.config/icm-sync/env";
in
{
  home.packages = [ sync ];

  # The token is not committed. It is injected from sops at activation into a
  # 0600 env file that only the systemd user unit reads.
  home.activation.icmSyncEnv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ENV_FILE=${lib.escapeShellArg envFile}
    install -d -m 0700 "$(dirname "$ENV_FILE")"
    umask 077
    {
      printf 'ICM_SYNC_URL=%s\n' "https://icm.arifinoid.web.id"
      printf 'ICM_SYNC_TOKEN=%s\n' "$(cat ${lib.escapeShellArg osConfig.sops.secrets.icm_sync_token.path})"
      printf 'ICM_SYNC_DEVICE=%s\n' "${hostName}"
    } > "$ENV_FILE.tmp"
    mv "$ENV_FILE.tmp" "$ENV_FILE"
  '';

  # Sync on a timer: the local database stays the source of truth for ICM and
  # its hooks, and every run pushes local edits and applies the server snapshot.
  systemd.user.services.icm-sync = {
    Unit = {
      Description = "ICM memory sync";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${sync}/bin/icm-sync";
      EnvironmentFile = envFile;
    };
  };

  systemd.user.timers.icm-sync = {
    Unit.Description = "ICM memory sync every 10 minutes";
    Timer = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
