# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  pkgs,
  inputs,
  ezModules,
  ...
}:

{
  imports = [
    # Include the generated hardware configuration
    ezModules.wsl-hardware
    ezModules.bun-overlay
    ezModules.common
    # Include NixOS-WSL configuration
    inputs.nixos-wsl.nixosModules.wsl
  ];

  # Build OpenSSH with GSSAPI support. Without it, `GSSAPIAuthentication`
  # is an unknown option and ssh warns on every Lima/Colima generated
  # ssh_config. (rust overlay comes from common.nix)
  nixpkgs.overlays = [
    (_final: prev: { openssh = prev.openssh_gssapi; })
  ];

  wsl.enable = true;
  wsl.defaultUser = "arifinoid"; # Changed from "nixos" to "arifinoid"

  # Host-specific user bits (base user in common.nix)
  users.users.arifinoid.extraGroups = [ "wheel" ];

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  # dynamically linked executables intended for generic linux environments out of the box. https://nix.dev/permalink/stub-ld
  programs.nix-ld.enable = true;

  services.openssh.enable = true;

  environment.variables = {
    WSL_DISTRO_NAME = "NixOS";
    WSL_INTEROP = "1";
    # nvim = daily driver (nano tetap terinstall sebagai fallback darurat)
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    MANPAGER = "less -R";
  };

  # SOPS + stateVersion + HM flags live in common.nix.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git

    nixd
    nix-search
    cachix
    fzf
    inputs.self.packages.${pkgs.system}.nvim
  ];

  services.ollama.enable = false;

  fonts.packages = with pkgs; [
    sketchybar-app-font

    # name of nerdfonts see {https://github.com/NixOS/nixpkgs/blob/nixos-24.11/pkgs/data/fonts/nerdfonts/shas.nix}
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    geist-font
  ];
}
