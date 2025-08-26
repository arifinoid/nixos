{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    alacritty
    bun
    cargo
    cmake
    colima
    docker
    docker-compose
    eslint
    fzf
    gcc
    go
    gofumpt
    goimports-reviser
    golangci-lint
    golines
    gopls
    jq
    lua5_4_compat
    marksman
    meson
    nixfmt-classic
    nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vercel
    pgsync
    pnpm
    postgresql
    pyright
    python314
    quick-lint-js
    rabbitmq-c
    redis
    rustc
    typescript
    typescript-language-server
    yarn
    zig
  ];

  programs.go.enable = true;
  programs.go.package = pkgs.go;

  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}