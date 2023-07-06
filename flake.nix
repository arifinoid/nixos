{
  description = "Home Manager configuration of arifinoid";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, home-manager, utils, ... }:
    utils.lib.eachDefaultSystem(system: 
    let pkgs = import nixpkgs{
        inherit system;
    };
    in {
      homeConfigurations = {
          arifinoid = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            # Specify your home configuration modules here, for example,
            # the path to your home.nix.
            modules = [ 
             ./home.nix
             ./home/tmux.nix
            ];
            # Optionally use extraSpecialArgs
            # to pass through arguments to home.nix
          };
      };
    });
}
