# Shared base for all NixOS hosts (bare metal + WSL).
# Host-specific stuff (desktop, bootloader, WSL, fonts, systemPackages)
# stays in nix/configurations/nixos/<host>.nix.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
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
    # cache.nixos.org tidak ditulis (sudah default NixOS)
    substituters = [
      "https://arifinoid-nix.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "arifinoid-nix.cachix.org-1:nWkuaaSkZMWvDUE+eTMi6sVZOHZs1YpiQ55J60qcj0A="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # lima via colima: versi ini ditandai insecure di nixpkgs baru.
  # Hapus baris ini kalau colima sudah pindah ke lima yang fixed.
  nixpkgs.config.permittedInsecurePackages = [
    "lima-1.0.7"
  ];
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

  # Base user; hosts add their own extraGroups/packages.
  users.users.arifinoid = {
    isNormalUser = true;
    description = "Rohmad Arifin";
    shell = pkgs.zsh;
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    zsh
    fish
  ];

  # SOPS secrets management (key file must exist on disk)
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secret.yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets = {
      llmkita_api_key = {
        owner = "arifinoid";
        group = "users";
        mode = "0400";
      };
      ox_alpha_api_key = {
        owner = "arifinoid";
        group = "users";
        mode = "0400";
      };
      wakatime_api_key = {
        owner = "arifinoid";
        group = "users";
        mode = "0400";
      };
    };
  };

  # Home Manager behavior (avoids clobber error on existing files)
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";

  system.stateVersion = "25.05"; # Did you read the comment?
}
