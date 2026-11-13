{
  config,
  pkgs,
  inputs,
  ...
}:

let
  # App env files are rendered from these at activation (see the sops.templates
  # in vps-adl.nix, vps-takar.nix and vps-web.nix). restartUnits means a value
  # change only needs `sops edit` + rebuild: sops-nix re-renders the file and
  # restarts the consumer, so no hand-edited /etc/*.env survives anywhere.
  mkSecret = restartUnits: {
    owner = "root";
    group = "root";
    mode = "0400";
    inherit restartUnits;
  };
in
{
  # Hermes lives outside the closure (/root/.local/bin/hermes) and rewrites its
  # own config at runtime — the /model picker writes back to it — so a read-only
  # store symlink is not an option. Copy the tracked version over on every
  # activation instead: writable for Hermes, but a deploy always lands on the
  # config committed in nix/scripts/hermes-config.yaml.
  system.activationScripts.hermes-config = ''
    install -D -m 0600 -o root -g root \
      ${inputs.self}/nix/scripts/hermes-config.yaml /root/.hermes/config.yaml
  '';

  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secret.yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    package = inputs.sops.packages.${pkgs.stdenv.hostPlatform.system}.sops-install-secrets;
    secrets = {
      nine_router_api_key = {
        owner = "root";
        group = "root";
        mode = "0400";
      };

      # ADL API (/etc/adl-api.env)
      adl_database_url = mkSecret [ "adl-api.service" ];
      adl_jwt_secret = mkSecret [ "adl-api.service" ];

      # ADL file service (/etc/adl-file-service.env)
      adl_r2_account_id = mkSecret [ "adl-file-service.service" ];
      adl_r2_access_key_id = mkSecret [ "adl-file-service.service" ];
      adl_r2_secret_access_key = mkSecret [ "adl-file-service.service" ];

      # Takar API (/etc/takar.env). takar-migrate and takar-alert-job read the
      # same file on every run, so only the long-running API needs a restart.
      takar_database_url = mkSecret [ "takar-api.service" ];
      takar_migrate_database_url = mkSecret [ "takar-api.service" ];
      takar_app_password = mkSecret [ "takar-api.service" ];
      takar_jwt_secret = mkSecret [ "takar-api.service" ];
      takar_brevo_api_key = mkSecret [ "takar-api.service" ];
      takar_fonnte_token = mkSecret [ "takar-api.service" ];

      # job-hooker API (/etc/jobhooker.env)
      jobhooker_api_token = mkSecret [ "jobhooker.service" ];
      jobhooker_database_url = mkSecret [ "jobhooker.service" ];
    };
    templates."/root/.9router/hermes-api-key" = {
      name = "root/.9router/hermes-api-key";
      path = "/root/.9router/hermes-api-key";
      content = config.sops.placeholder.nine_router_api_key;
      mode = "0400";
      owner = "root";
      group = "root";
    };
    templates."/root/.config/environment.d/99-nine-router.conf" = {
      name = "root/.config/environment.d/99-nine-router.conf";
      path = "/root/.config/environment.d/99-nine-router.conf";
      content = "NINE_ROUTER_API_KEY=${config.sops.placeholder.nine_router_api_key}";
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };
}
