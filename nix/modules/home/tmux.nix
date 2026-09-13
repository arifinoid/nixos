{ inputs, pkgs, ... }:
{
  xdg.configFile."herdr/config.toml".source = ./herdr.toml;
  home.packages = [ inputs.herdr.packages.${pkgs.system}.default ];
}
