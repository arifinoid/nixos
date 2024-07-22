{ pkgs, lib, ... }:
let
  nixConfigDirectory = "~/.config/nixpkgs";
  username = "arifinoid";
  homeDirectory =
    "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${username}";
in
{
  home.packages = with pkgs;
    [
      asciiquarium
      asciinema
      openssh
      # openvpn
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
      # alacritty
      nodejs_18 # currently defined in devShells.nix
      yarn # currently defined in devShells.nix
      quick-lint-js
      nixfmt
      bun
      gopls
      python39
      rustc
      cargo
      zig
      fishPlugins.bass
      speedtest-cli
      docker
      docker-compose
      colima
      slack
      zoom-us
      # postman # this is not working now on new version
      redis
      zbar
      git-filter-repo
      postgresql
      rabbitmq-c
      silicon
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      # Add packages only for Linux
      gcc9
      libstdcxx5
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
      blackbox-terminal
      gparted
      insomnia
      google-authenticator
      nettools
      stacer
      # obs-studio
      lua5_4_compat
      jq

      mesa_drivers # OpenGL drivers for most systems
      intel-media-driver
      mesa
      libdrm
      libglvnd
      egl-wayland
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      # Add packages only for Darwin (MacOS)
      cocoapods
      m-cli # useful macOS CLI commands
      xcode-install
    ];

  programs.go.enable = true;
  programs.go.package = pkgs.go;
  programs.go.goPath = "${homeDirectory}/go";
  programs.go.goBin = "${homeDirectory}/go/bin/";

  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}
