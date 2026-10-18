# Tooling agent: rtk & icm (dari GitHub release, lihat packages/agent-cli.nix)
# plus binary installer lain di ~/.local/bin (claude, agy).
#
# Installer rtk/icm nulis ke ~/.local/bin, tapi PATH sistem NixOS cuma nyertain
# profile nix — makanya dulu harus `nix develop` dulu. Sekarang keduanya nix
# package, jadi langsung kepakai dari shell biasa.
#
# Catatan: modul ini home-manager, jadi HANYA ngejalan di host yang pakai HM
# (arifinoid + wsl-arifinoid). VPS tidak kena.
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

  # ~/.local/bin (claude, agy, binary installer lain) di-APPEND, bukan di-prepend:
  # rtk/icm harus resolve ke versi nix, bukan hasil installer lama di sana.
  # NOTE: prefix PATH lewat sessionVariables.PATH = mkForce "...:${...PATH}" bikin
  # infinite recursion di module system, makanya lewat init shell.
  programs.zsh.initContent = ''
    typeset -U path
    path=($path "$HOME/.local/bin")
    export PATH
  '';

  programs.fish.shellInit = ''
    fish_add_path --path "$HOME/.local/bin" --append
  '';

  home.sessionVariables = {
    # Sama dengan shellHook ai-optimizer, biar `pipx install` mendarat di
    # ~/.local/bin, bukan default ~/.local/pipx/bin yang gak ada di PATH.
    PIPX_HOME = "${config.home.homeDirectory}/.local/pipx";
    PIPX_BIN_DIR = "${config.home.homeDirectory}/.local/bin";
  };

  # rtk init menulis hook ke ~/.config/rtk; icm MCP ke ~/.config/opencode.
  # Foldernya cukup ada; isinya tetap milik installer (bukan aset nix).
  home.activation.createToolDirs = lib.hm.dag.entryBefore [ "linkDotFiles" ] ''
    mkdir -p "$HOME/.config/rtk" "$HOME/.local/pipx"
  '';
}
