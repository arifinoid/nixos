{
  pkgs,
  inputs,
  ezModules,
  ...
}:

{
  imports = [
    ezModules.wsl-hardware
    ezModules.bun-overlay
    ezModules.common
    inputs.nixos-wsl.nixosModules.wsl
  ];

  nixpkgs.overlays = [
    (_final: prev: { openssh = prev.openssh_gssapi; })
  ];

  wsl.enable = true;
  wsl.defaultUser = "arifinoid";

  users.users.arifinoid.extraGroups = [ "wheel" ];

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.nix-ld.enable = true;

  services.openssh.enable = true;

  environment.variables = {
    WSL_DISTRO_NAME = "NixOS";
    WSL_INTEROP = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    MANPAGER = "less -R";
  };

  # SOPS + stateVersion + HM flags live in common.nix.

  environment.systemPackages = with pkgs; [
    vim
    wget
    git

    nixd
    nix-search
    cachix
    fzf
    inputs.self.packages.${pkgs.system}.nvim
  ];

  fonts.packages = with pkgs; [
    sketchybar-app-font

    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    geist-font
  ];
}
