{
  description = "Home Manager configuration of arifinoid";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, utils, nixvim, ... } @inputs:
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
                    flakeup =
                      # example flakeup nixpkgs-unstable
                      "nix flake lock ${nixConfigDirectory} --update-input";
                    nxb = "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result ";
                    nxa = "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                  };
                })

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

        environment.systemModules = [
          (nixvim.legacyPackages."${system}".makeNixvim {
            colorschemes.gruvbox.enable = true;
          })
        ];

        imports = [
          # For home-manager
          nixvim.homeManagerModules.nixvim
          # For NixOS
          nixvim.nixosModules.nixvim
          # For nix-darwin
          nixvim.nixDarwinModules.nixvim
        ];

        programs.nixvim.enable = true;
      });
}
