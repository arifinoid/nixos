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

  outputs = { self, nixpkgs, home-manager, utils, ... } @inputs:
    utils.lib.eachDefaultSystem(system: 
    let
      config = { allowUnfree = true; };
      pkgs = import nixpkgs {
        inherit system;
        config = config;
      };

      defaultNixpkgs = {
        inherit config;
      };
    in {
        homeConfigurations = {
            arifinoid = home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                # Specify your home configuration modules here, for example,
                # the path to your home.nix.
                modules = [ 
                 ./home.nix
                 ./home/git.nix
                 ./home/nvim.nix
                 ./home/packages.nix
                 ./home/shells.nix
                 ./home/tmux.nix
                ];
                # Optionally use extraSpecialArgs
                # to pass through arguments to home.nix
            };
        };

        legacyPackages = import inputs.nixpkgs (defaultNixpkgs // { inherit system; });

        devShells = import ./devShells.nix {
            pkgs = self.legacyPackages.${system};
        };
    });
}
