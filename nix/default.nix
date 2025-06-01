{ inputs, ... }:
{
  imports = [
    inputs.ez-configs.flakeModule
  ];

  ezConfigs = {
    root = ./.;
    home.configurationsDirectory = ./configurations/home;
    nixos.configurationsDirectory = ./configurations/nixos;
    home.modulesDirectory = ./modules/home;
    nixos.modulesDirectory = ./modules/nixos;

    globalArgs = {
      inherit inputs;
    };
    nixos.hosts = {
      arifinoid.userHomeModules = ["arifinoid"];
    };

  };

  perSystem =
    {
      pkgs,
      config,
      system,
      ...
    }:
    {
      pre-commit.settings.hooks = {
        deadnix.enable = true;
        nixfmt-rfc-style.enable = true;
      };

      packages = { };

      devShells = {
        default = pkgs.mkShell { };
        nodejs = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs
          ];
        };
      };
    };
}
