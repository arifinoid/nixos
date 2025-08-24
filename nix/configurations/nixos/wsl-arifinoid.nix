# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, ezModules, ... }:

{
  imports = [
    # Include the generated hardware configuration
    ezModules.wsl-hardware
    # Include NixOS-WSL configuration
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl.enable = true;
  wsl.defaultUser = "arifinoid"; # Changed from "nixos" to "arifinoid"

  # User configuration - minimal to avoid builds
  users.users.arifinoid = {
    isNormalUser = true;
    description = "Rohmad Arifin";
    extraGroups = [ "wheel" ];
    packages = [];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  programs.tmux.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;


  services.openssh.enable = true;
  services.getty.autologinUser = "arifinoid";

  # Minimal environment
  environment.shells = with pkgs; [ fish ];
  
  environment.variables = {
    WSL_DISTRO_NAME = "NixOS";
    WSL_INTEROP = "1";
    EDITOR = "nano";
    VISUAL = "nano";
    PAGER = "less";
    MANPAGER = "less -R";
  };

  # System settings
  system.stateVersion = "25.05"; # Did you read the comment?
}
