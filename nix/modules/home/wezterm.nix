{
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  xdg.configFile."wezterm/wezterm.lua".source = "${inputs.self}/.config/wezterm/wezterm.lua";

  home.packages = [ pkgs.wezterm ];
}
