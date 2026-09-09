{
  pkgs,
  inputs,
  ...
}:
{
  xdg.configFile."wezterm/wezterm.lua".source = "${inputs.self}/.config/wezterm/wezterm.lua";

  home.packages = [ pkgs.wezterm ];
}
