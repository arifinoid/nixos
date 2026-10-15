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

      # Pengganti git-hooks-nix flakeModule (di-drop total, lihat flake.nix):
      # deadnix + nixfmt langsung sebagai check derivation. Tanpa perantara
      # yang rawan skew versi (cspell/dotnet) seperti yang terjadi.
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
            # NOTE: nama paket = nixfmt-rfc-style, nama binari = nixfmt.
            # (Di nixpkgs-stable kita keduanya beda; di unstable sudah merger.
            #  Jangan disamakan tanpa cek `nix build .#formatter`.)
            # shellcheck disable=SC2046
            nixfmt --check $(find . -name '*.nix' -not -path './.git/*')
            touch $out
          '';
    };
}
