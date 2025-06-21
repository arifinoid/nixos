{ inputs, ... }: {
  imports = [ inputs.ez-configs.flakeModule ./nixvim ];

  ezConfigs = {
    root = ./.;
    home = {
      configurationsDirectory = ./configurations/home;
      modulesDirectory = ./modules/home;
    };
    nixos = {
      configurationsDirectory = ./configurations/nixos;
      modulesDirectory = ./modules/nixos;
    };

    globalArgs = { inherit inputs; };
    nixos.hosts = { arifinoid.userHomeModules = [ "arifinoid" ]; };

  };

  perSystem = { pkgs, system, ... }: {
    pre-commit.settings.hooks = {
      deadnix.enable = true;
      nixfmt-rfc-style.enable = true;
    };

    packages = {
      nixvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit system;
        module = import ./nixvim/config;
        extraSpecialArgs = { inherit inputs; };
      };
    };

    devShells = {
      default = pkgs.mkShell { };
      nodejs = pkgs.mkShell { buildInputs = [ pkgs.nodejs ]; };
    };
  };
}
