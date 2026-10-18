# Tooling agent yang di-install ke ~/.local/bin (rtk, icm, claude, agy).
#
# Installer masing-masing nulis binary ke ~/.local/bin, tapi PATH sistem NixOS
# cuma nyertain profile nix — jadi rtk/icm cuma kelihatan setelah masuk
# `nix develop` project (dulu: ai-optimizer). Modul ini bikin keduanya langsung
# kepakai dari shell biasa, tanpa nix develop.
{
  config,
  lib,
  ...
}:

{
  # NOTE: prefix PATH lewat sessionVariables.PATH = mkForce "...:${...PATH}"
  # bikin infinite recursion di module system, jadi lewat init shell.
  programs.zsh.initContent = ''
    # rtk, icm, claude, agy (installer di luar nix)
    typeset -U path
    path=("$HOME/.local/bin" $path)
    export PATH
  '';

  programs.fish.shellInit = ''
    fish_add_path --path "$HOME/.local/bin" --prepend
  '';

  home.sessionVariables = {
    # Sama dengan shellHook ai-optimizer, biar `pipx install` mendarat di
    # ~/.local/bin (yang sekarang udah ada di PATH), bukan default
    # ~/.local/pipx/bin yang gak ada di PATH sistem.
    PIPX_HOME = "${config.home.homeDirectory}/.local/pipx";
    PIPX_BIN_DIR = "${config.home.homeDirectory}/.local/bin";
  };

  # rtk init menulis hook ke ~/.config/rtk; icm MCP ke ~/.config/opencode.
  # Foldernya cukup ada; isinya tetap milik installer (bukan aset nix).
  home.activation.createToolDirs = lib.hm.dag.entryBefore [ "linkDotFiles" ] ''
    mkdir -p "$HOME/.config/rtk" "$HOME/.local/pipx"
  '';
}
