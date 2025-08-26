{ pkgs, ... }:
{
  home.packages = with pkgs; [
    asciiquarium
    asciinema
    openssh
    openvpn
    curl
    wget
    fzf
    ack
    neofetch
    ripgrep
    stow
    trash-cli
    pass
    xclip
    xsel
    speedtest-cli
    blackbox-terminal
    gparted
    insomnia
    google-authenticator
    nettools
    stacer
    obs-studio
    unzip

    mesa # OpenGL drivers for most systems
    intel-media-driver
    mesa
    libdrm
    libglvnd
  ];
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}