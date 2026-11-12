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

  # systemd's fstab generator ignores swap entries when running in a container
  # (WSL2 counts as one), so `swapDevices` alone never activates this file.
  # Extra headroom so nixos-rebuild is not OOM-killed while cargo/clippy runs.
  systemd.services.swapfile = {
    description = "Enable 4 GiB swapfile";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    path = [
      pkgs.util-linux
      pkgs.e2fsprogs
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.util-linux}/bin/swapoff /swapfile";
    };
    script = ''
      if [ ! -e /swapfile ]; then
        dd if=/dev/zero of=/swapfile bs=1M count=4096 status=none
        chmod 600 /swapfile
        mkswap /swapfile
      fi
      if ! grep -q '^/swapfile ' /proc/swaps; then
        swapon /swapfile
      fi
    '';
  };

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
