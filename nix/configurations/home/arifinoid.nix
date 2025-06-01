{
  lib,
  ezModules,
  osConfig,
  pkgs,
  inputs,
  ...
}:

{
  home = rec {
    username = "arifinoid";
    stateVersion = "25.05";
    homeDirectory = osConfig.users.users.${username}.home;
    packages = [ ];
  };

  imports = lib.attrValues ezModules;
}
