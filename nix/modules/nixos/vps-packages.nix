{ pkgs, inputs, ... }:
let
  npmCli = pkgs.callPackage "${inputs.self}/nix/packages/npm-cli.nix" { };
  nineRouterApp = "${npmCli."9router"}/lib/node_modules/9router/app";

  # pg_dump/pg_restore/psql for deploy/vps/backup.sh. Must be at least the
  # Neon server major version (18); 25.05 only ships 17.
  postgresql =
    inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.postgresql_18;
in
{
  environment.systemPackages = with pkgs; [
    git
    gh
    fastfetch
    btop
    neovim
    python3
    nodejs
    bun
    postgresql
    pm2
    certbot
    nginx

    bat
    eza
    zsh-completions

    npmCli."9router"
  ];

  systemd.services.nine-router = {
    description = "9router LLM gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_24}/bin/node --dns-result-order=ipv4first ${nineRouterApp}/custom-server.js";
      WorkingDirectory = nineRouterApp;
      Environment = [
        "HOME=/root"
        "PORT=20128"
        "HOSTNAME=127.0.0.1"
        "NODE_ENV=production"
        "PATH=/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      ExitType = "cgroup";
    };
  };
}
