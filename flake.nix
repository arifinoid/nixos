{
  description = "Home Manager configuration of arifinoid";

  inputs = {
    nix.url = "github:nixos/nix";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    ## -- nixpkgs 
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    utils.url = "github:numtide/flake-utils";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # secret management 
    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , nixvim
    , utils
    , sops
    , ...
    }:
    utils.lib.eachDefaultSystem (system:
    let
      config = { allowUnfree = true; };
      pkgs = import nixpkgs {
        inherit system;
        config = config;
      };

      defaultNixpkgs = { inherit config; };

      overlay-unstable = final: prev: {
        unstable = inputs.nixpkgs.legacyPackages.${system};
      };
    in
    {
      nixpkgs.overlays = [ overlay-unstable ];
      nixpkgs.config = { allowUnfree = true; };
      homeConfigurations = {
        nixvimUser = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules =
            [ nixvim.homeManagerModules.nixvim ./home/nixvim/default.nix ];
        };
        arifinoid = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            sops.homeManagerModules.sops
            ({ pkgs, ... }:
              let
                nixConfigDirectory = "~/.config/nixpkgs";
                username = "arifinoid";
                homeDirectory = "/${
                      if pkgs.stdenv.isDarwin then "Users" else "home"
                    }/${username}";
              in
              {
                home = {
                  stateVersion = "23.11";
                  username = username;
                  homeDirectory = homeDirectory;
                  shellAliases = {
                    flakeup =
                      # example flakeup nixpkgs-unstable
                      "nix flake lock ${nixConfigDirectory} --update-input";
                    nxb =
                      "nix build ${nixConfigDirectory}/#homeConfigurations.${system}.${username}.activationPackage -o ${nixConfigDirectory}/result ";
                    nxa =
                      "${nixConfigDirectory}/result/activate switch --flake ${nixConfigDirectory}/#homeConfigurations.${system}.${username}";
                  };
                };

                fonts.fontconfig.enable = true;

                home.sessionVariables = {
                  LIBGL_ALWAYS_SOFTWARE = "1";
                  LIBGL_DRIVERS_PATH = "/usr/lib/x86_64-linux-gnu/dri";
                  MESA_LOADER_DRIVER_OVERRIDE = "iris";
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

      legacyPackages =
        import inputs.nixpkgs (defaultNixpkgs // { inherit system; });

      devShells =
        import ./devShells.nix { pkgs = self.legacyPackages.${system}; };
    });
}
