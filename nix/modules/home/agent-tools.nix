{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  agentCli = pkgs.callPackage "${inputs.self}/nix/packages/agent-cli.nix" { };
in
{
  home.packages = [
    agentCli.rtk
    agentCli.icm
  ];

  programs.zsh.initContent = ''
    typeset -U path
    path=($path "$HOME/.local/bin")
    export PATH
  '';

  programs.fish.shellInit = ''
    fish_add_path --path "$HOME/.local/bin" --append
  '';

  home.sessionVariables = {
    PIPX_HOME = "${config.home.homeDirectory}/.local/pipx";
    PIPX_BIN_DIR = "${config.home.homeDirectory}/.local/bin";
  };

  home.activation.createToolDirs = lib.hm.dag.entryBefore [ "linkDotFiles" ] ''
    mkdir -p "$HOME/.config/rtk" "$HOME/.local/pipx"
  '';
}
