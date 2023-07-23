{ config, pkgs, lib, ... }:

{
  home.username = "arifinoid";
  home.homeDirectory = "/home/arifinoid";
  home.stateVersion = "23.05";
  # home.activation = {
   # defaultShell = lib.hm.dag.entryAfter [
    #    "WriteBoundary"
    #] ''
    #sudo ${pkgs.util-linux}/bin/chsh -s /home/arifinoid/.nix-profile/bin/fish
    #'';
  #};

  home.shellAliases = {
    hmb = "nix build ~/.config/home-manager#homeConfigurations.x86_64-linux.arifinoid.activationPackage -o ~/.config/home-manager/result";
    hmo = "~/.config/home-manager/result/activate";
  };
  home.sessionVariables = {};
}
