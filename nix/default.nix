{ inputs, ... }: {
  imports = [ inputs.ez-configs.flakeModule ./nixvim ];

  flake = { icons = import ./icons.nix; };

  ezConfigs = {
    root = ./.;
    home = {
      configurationsDirectory = ./configurations/home;
      modulesDirectory = ./modules/home;
    };
    nixos = {
      configurationsDirectory = ./configurations/nixos;
      modulesDirectory = ./modules/nixos;
      hosts = { arifinoid.userHomeModules = [ "arifinoid" ]; };
    };

    globalArgs = {
      inherit (inputs) self;
      inherit inputs;
      inherit (inputs.self) icons;
    };
  };

  perSystem = { pkgs, system, icons, helpers, ... }: {
    pre-commit.settings.hooks = {
      deadnix.enable = true;
      nixfmt-rfc-style.enable = true;
    };

    devShells = {
      default = pkgs.mkShell { };
      nodejs = pkgs.mkShell { buildInputs = [ pkgs.nodejs ]; };
    };

    _module.args = {
      inherit (inputs.self) icons colors color;
      extraModuleArgs = { inherit (inputs.self) icons colors color; };
      pkgs = import inputs.nixpkgs {
        inherit system;
        inherit (inputs.nixpkgs);
      };
    };
  };
}
