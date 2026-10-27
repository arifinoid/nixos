{ inputs, ... }:
{
  imports = [
    inputs.ez-configs.flakeModule
    ./nixvim
  ];

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
    nixos.hosts = {
      arifinoid.userHomeModules = [ "arifinoid" ];
      "wsl-arifinoid" = {
        userHomeModules = [ "arifinoid" ];
      };
    };

  };

  perSystem =
    { pkgs, ... }:
    {
      # Provide formatter for `nix fmt`
      formatter = pkgs.nixfmt-rfc-style;

      devShells = {
        default = pkgs.mkShell { };
        nodejs = pkgs.mkShell { buildInputs = [ pkgs.nodejs ]; };
      };

      checks.pre-commit =
        pkgs.runCommand "pre-commit-check"
          {
            src = inputs.self;
            nativeBuildInputs = with pkgs; [
              deadnix
              nixfmt-rfc-style
            ];
          }
          ''
            cd "$src"
            deadnix --fail .
            nixfmt --check $(find . -name '*.nix' -not -path './.git/*')
            touch $out
          '';
    };
}
