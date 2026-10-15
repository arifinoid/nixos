{ pkgs, osConfig, ... }:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  home.packages =
    with pkgs;
    [
      asciiquarium
      asciinema
      openvpn
      curl
      wget
      fzf
      ack
      fastfetch
      ripgrep
      trash-cli
      pass
      speedtest-cli
      google-authenticator
      nettools
      obs-studio
      unzip
    ]
    ++ lib.optionals (!isWSLHost) [
      # X11 clipboard: tidak ada gunanya di WSL
      xclip
      xsel
      openssh
      stow
      blackbox-terminal
      gparted
      insomnia
      mesa # OpenGL drivers for most systems
      intel-media-driver
      libdrm
      libglvnd
    ];
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}
