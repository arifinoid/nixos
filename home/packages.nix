{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    asciiquarium
    openssh
    curl
    wget
    ack
    neofetch
    ripgrep
    stow
    trash-cli
    xclip
    xsel
    openvpn
    alacritty
    nodejs_18 # currently defined in devShells.nix
    yarn # currently defined in devShells.nix
    bun
    go
    python39
    nerdfonts
    rustc
    cargo
    zig
    fishPlugins.bass
    speedtest-cli
    docker
    colima
    slack
    zoom-us
    postman
    dbeaver
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Add packages only for Linux
    openvpn3
    gcc9
    libstdcxx5
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    cloudflare-warp
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # Add packages only for Darwin (MacOS)
    cocoapods
    m-cli # useful macOS CLI commands
    xcode-install
  ];
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;


  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;
}
