
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
    alacritty
    nodejs # currently defined in devShells.nix
    yarn # currently defined in devShells.nix
    quick-lint-js
    nixfmt
    bun
    gopls
    python314
    rustc
    cargo
    zig
    fishPlugins.bass
    speedtest-cli
    docker
    docker-compose
    colima
    redis
    zbar
    git-filter-repo
    postgresql
    rabbitmq-c
    silicon
    sops
    age

    gcc9
    blackbox-terminal
    gparted
    insomnia
    google-authenticator
    nettools
    stacer
    obs-studio
    lua5_4_compat
    jq

    mesa # OpenGL drivers for most systems
    intel-media-driver
    mesa
    libdrm
    libglvnd
    egl-wayland
  ];
  programs.go.enable = true;
  programs.go.package = pkgs.go;

  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}
