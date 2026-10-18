# Tooling agent: rtk & icm (lihat packages/agent-cli.nix) plus binary installer
# lain di ~/.local/bin (claude, agy).
#
# Installer rtk/icm dulu nulis ke ~/.local/bin, sementara PATH sistem NixOS cuma
# nyertain profile nix — jadi toolnya cuma kelihatan setelah `nix develop`.
# Sekarang keduanya nix package.
#
# Plugin integrasinya (~/.config/opencode/plugins/{rtk,icm}.ts) tetap milik
# installer: isinya memanggil `rtk rewrite` / `icm extract` saat opencode jalan.
#
# Modul home-manager, jadi hanya ngejalan di arifinoid + wsl-arifinoid; VPS tidak
# punya HM sehingga tidak kena.
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

  # ~/.local/bin di-APPEND, bukan di-prepend: rtk/icm harus resolve ke versi nix,
  # bukan binary installer lama yang masih nangkring di sana.
  # (Prefix PATH lewat sessionVariables.PATH = mkForce "...:${...PATH}" bikin
  # infinite recursion di module system — itu sebabnya lewat init shell.)
  programs.zsh.initContent = ''
    typeset -U path
    path=($path "$HOME/.local/bin")
    export PATH
  '';

  programs.fish.shellInit = ''
    fish_add_path --path "$HOME/.local/bin" --append
  '';

  # Samakan dengan shellHook ai-optimizer: pipx install mendarat di ~/.local/bin.
  home.sessionVariables = {
    PIPX_HOME = "${config.home.homeDirectory}/.local/pipx";
    PIPX_BIN_DIR = "${config.home.homeDirectory}/.local/bin";
  };

  home.activation.createToolDirs = lib.hm.dag.entryBefore [ "linkDotFiles" ] ''
    mkdir -p "$HOME/.config/rtk" "$HOME/.local/pipx"
  '';
}
