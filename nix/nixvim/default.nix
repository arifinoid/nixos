# Nixvim via flake-parts API modern (nixvim >= 2026):
# - `flakeModules.nixvimConfigurations` (TANPA `.default`, supaya tidak
#   menyeret `partitions` nixvim yang akan memindahkan checks/devShells/
#   formatter kita ke partition nixvim).
# - packages/checks di-wire manual dari `config.nixvimConfigurations`.
{ inputs, ... }:
{
  imports = [
    inputs.nixvim.flakeModules.nixvimConfigurations
  ];

  perSystem =
    { config, system, ... }:
    let
      nixvimLib = inputs.nixvim.lib;
      # NOTE: pakai .extend, JANGAN `//`. `//` memutus fixpoint makeExtensible
      # sehingga helper custom hilang saat test.nix me-re-eval via .extend.
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
          # TANPA override nixpkgs.pkgs: pakai unstable bawaan nixvim supaya
          # versi paket (LSP servers, plugins) cocok dengan skema modul baru.
          # Unfree dibutuhkan (copilot-language-server).
          { nixpkgs.config.allowUnfree = true; }
          # nixpkgs.source eksplisit = input nixvim sendiri (nilai identik
          # dengan default). Tanpa ini, check `nix flake check` gagal hanya
          # karena warning skew-rev lockfile (bukan error beneran).
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
