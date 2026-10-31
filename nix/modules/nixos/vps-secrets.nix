{
  config,
  pkgs,
  inputs,
  ...
}:
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
    secrets.nine_router_api_key = {
      owner = "root";
      group = "root";
      mode = "0400";
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
