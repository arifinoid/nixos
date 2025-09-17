{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  home.packages =
    with pkgs;
    [
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
      go-migrate
      gopls
      jq
      k9s
      lua5_4_compat
      marksman
      meson
      minikube
      nixfmt-classic
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.vercel
      pgsync
      pnpm
      podman
      podman-compose
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
    ]
    ++ lib.optionals (!isWSLHost) [ alacritty ];

  programs.go.enable = true;
  programs.go.package = pkgs.go;

  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };
}
