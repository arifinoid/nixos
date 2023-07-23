{ pkgs, lib, ... }:

let
  recursiveMergeAttrs = listOfAttrsets: lib.fold (attrset: acc: lib.recursiveUpdate attrset acc) { } listOfAttrsets;

  makeNodeShell = { nodejs, python ? pkgs.python3 }:
    let
      nodePackages = pkgs.nodePackages.override {
        inherit nodejs;
      };
    in
    pkgs.mkShell {
      buildInputs = [ python ];
      packages = [
        nodejs
        nodePackages.yarn
        (nodePackages.pnpm.override {
          version = "5.18.7";
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/pnpm/-/pnpm-5.18.7.tgz";
            sha512 = "7LSLQSeskkDtzAuq8DxEcVNWlqFd0ppWPT6Z4+TiS8SjxGCRSpnCeDVzwliAPd0hedl6HuUiSnDPgmg/kHUVXw==";
          };
        })
      ];
    };
  # for use devShell
  # write a file .envrc in some directory with contents:
  # use nix-env [devShell_Name]
  #
  # for [devShell_Name] see the attributes set of devShells
  # you can combine one or many devShell on environment, example:
  # use nix-env go node14
  devShells = with pkgs; {
    node18 = makeNodeShell {
      nodejs = nodejs-18_x;
      python = python3;
    };

    go = mkShell
      { packages = [ go ]; };
  };

  useNixShell =
    {
      xdg.configFile."direnv/lib/use_nix-env.sh".text = ''
        function use_nix-env(){
          for name in $@; do
            . "$HOME/.config/direnv/nix-envs/''${name}/env"
          done
        }
      '';
    };

  toWriteShell = name: devShell: { xdg.configFile."direnv/nix-envs/${name}".source = devShell; };

  devShellsConfigurations = [ useNixShell ]
    ++ lib.attrsets.mapAttrsToList toWriteShell devShells;

in

recursiveMergeAttrs
  devShellsConfigurations

