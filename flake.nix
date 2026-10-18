{
  description = "NixOS flake of arifinoid";

  outputs =
    inputs:
    let
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        systems = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];

        imports = [
          ./nix
        ];
      };
    in
    flake
    // {
      nix = {
        caches = [ "https://arifinoid-nix.cachix.org" ];
        extraTrustedPublicKeys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "arifinoid-nix.cachix.org-1:nWkuaaSkZMWvDUE+eTMi6sVZOHZs1YpiQ55J60qcj0A="
        ];
      };
    };

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/release-25.05";
    nixpkgs.follows = "nixpkgs-stable";

    # Unstable: cuma buat package yang di 25.05 udah ketuaan
    # (saat ini: claude-code & opencode). Lihat development.nix.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # utils
    flake-parts.url = "github:hercules-ci/flake-parts";

    # nixos wsl
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    # home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Secret Ops: SENGAJA tidak follows — butuh nixpkgs bawaannya sendiri
    # (unstable) karena helper Go-nya butuh toolchain >= 1.26.
    sops.url = "github:Mic92/sops-nix";

    # Ez
    ez-configs.url = "github:ehllie/ez-configs";
    ez-configs.inputs.nixpkgs.follows = "nixpkgs";
    ez-configs.inputs.flake-parts.follows = "flake-parts";

    # Nixvim
    # NOTE: nixvim main WAJIB nixpkgs yang module system-nya support
    # `valueMeta` (fitur 2026). Stable kita ketuaan, jadi follows DICABUT:
    # nixvim pakai nixos-unstable bawaannya, sistem tetap stable.
    # Konsekuensi: pkgs di dalam config nvim = stable (di-inject manual
    # di nix/nixvim/default.nix), tapi lib/schema = baru.
    nixvim = {
      url = "github:nix-community/nixvim";
    };

    # Browser
    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Herdr
    herdr.url = "github:herdrdev/herdr/v0.9.0";

    # Oh My Pi coding agent
    omp.url = "github:can1357/oh-my-pi";
  };
}
