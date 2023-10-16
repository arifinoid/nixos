{ lib, pkgs, ... }:
{
  # See https://github.com/nix-community/nix-direnv
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  users.users.arifinoid = {
    isNormalUser = true;
    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "obsidian"
      "spotify"
      # "discord"
      # "nvidia-persistenced"
      # "nvidia-x11"
      # "nvidia-settings"
      # "1password"
      # "1password-cli"
      # "steam"
      # "steam-run"
      # "steam-original"
      # "parsec-bin"
    ];
}
