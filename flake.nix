{
  description = "Home Manager configuration of arifinoid";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
    neovim-flake = {
      url = "github:neovim/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, utils, ... } @inputs:
    utils.lib.eachDefaultSystem (system:
      let
        config = { allowUnfree = true; };
        pkgs = import nixpkgs {
          inherit system;
          config = config;
        };

        defaultNixpkgs = {
          inherit config;
        };
      in
      {
        homeConfigurations = {
          arifinoid = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ({ pkgs, ... }:
                let
                  nixConfigDirectory = "~/.config/nixpkgs";
                  username = "arifinoid";
                  homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";
                in
                {

                  home.stateVersion = "23.05";
                  home.username = username;
                  home.homeDirectory = homeDirectory;
                  home.shellAliases = {
                    nxb = "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result ";
                    nxa = "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                  };
                })

              ./home/common.nix
              ./home/git.nix
              ./home/nvim.nix
              ./home/packages.nix
              ./home/shells.nix
              ./home/tmux.nix
            ];
          };
        };

        legacyPackages = import inputs.nixpkgs (defaultNixpkgs // { inherit system; });

        devShells = import ./devShells.nix {
          pkgs = self.legacyPackages.${system};
        };
      });
}
