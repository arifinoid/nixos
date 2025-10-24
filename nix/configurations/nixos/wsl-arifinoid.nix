# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{
  config,
  pkgs,
  inputs,
  ezModules,
  ...
}:

{
  imports = [
    # Include the generated hardware configuration
    ezModules.wsl-hardware
    # Include NixOS-WSL configuration
    inputs.nixos-wsl.nixosModules.wsl
    inputs.sops.nixosModules.sops
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "arifinoid"
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  wsl.enable = true;
  wsl.defaultUser = "arifinoid"; # Changed from "nixos" to "arifinoid"

  # User configuration - minimal to avoid builds
  users.users.arifinoid = {
    isNormalUser = true;
    description = "Rohmad Arifin";
    extraGroups = [ "wheel" ];
    packages = [ ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  programs.tmux.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  # dynamically linked executables intended for generic linux environments out of the box. https://nix.dev/permalink/stub-ld
  programs.nix-ld.enable = true;

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

  # SOPS secrets management (key file must exist on disk)
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secret.yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = { };
  };

  # Home Manager backup behavior (avoids clobber error on existing files)
  home-manager.backupFileExtension = "backup";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    kdePackages.partitionmanager

    nixd
    nix-search
    cachix
    fzf
    inputs.self.packages.${pkgs.system}.nvim
  ];
  services.ollama.enable = true;
  services.ollama.package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.ollama;

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
