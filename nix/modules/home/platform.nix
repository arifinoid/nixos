{ pkgs, osConfig, ... }:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  home.packages = with pkgs; [
    asciiquarium
    asciinema
    openvpn
    curl
    wget
    fzf
    ack
    neofetch
    fastfetch
    ripgrep
    trash-cli
    pass
    xclip
    xsel
    speedtest-cli
    google-authenticator
    nettools
    stacer
    obs-studio
    unzip
  ] ++ lib.optionals (!isWSLHost) [ 
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