# Nixvim via the modern flake-parts API (nixvim >= 2026):
# - `flakeModules.nixvimConfigurations` (WITHOUT `.default`, so it does not
#   drag in nixvim's `partitions`, which would move our checks/devShells/
#   formatter into a nixvim partition).
# - packages/checks are wired manually from `config.nixvimConfigurations`.
{ inputs, ... }:
{
  imports = [
    inputs.nixvim.flakeModules.nixvimConfigurations
  ];

  perSystem =
    { config, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib;
      # NOTE: use .extend, NOT `//`. `//` breaks the makeExtensible fixpoint,
      # so custom helpers disappear when test.nix re-evaluates through .extend.
      helpers = nixvimLib.nixvim.extend (
        _final: _prev: {
          mkLuaFunWithName =
            name: lua:
            # lua
            ''

              function ${name}()
                ${lua}
              end
            '';

          mkLuaFun =
            lua: # lua
            ''

              function()
                ${lua}
              end
            '';
        }
      );
    in
    {
      nixvimConfigurations.nvim = nixvimLib.evalNixvim {
        inherit system;
        modules = [
          # Do NOT override nixpkgs.pkgs: use nixvim's bundled unstable so
          # package versions (LSP servers, plugins) match the new module schema.
          # Unfree is required (copilot-language-server).
          { nixpkgs.config.allowUnfree = true; }
          # nixpkgs.source is set explicitly to nixvim's own input (identical
          # to the default). Without this, `nix flake check` fails only because
          # of a lockfile skew-rev warning (not a real error).
          (
            { inputs, ... }:
            {
              nixpkgs.source = inputs.nixvim.inputs.nixpkgs;
            }
          )
          ./config
        ];
        extraSpecialArgs = {
          inherit
            helpers
            system
            inputs
            ;
          icons = import ../icons.nix;
        };
      };

      packages.nvim = config.nixvimConfigurations.nvim.config.build.package;

      checks.nvim = config.nixvimConfigurations.nvim.config.build.test;
    };
}
