{
  pkgs,
  osConfig,
  lib,
  ...
}:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
    ];
  };
in
{
  home.packages =
    with pkgs;
    [
      bun
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
      # nodePackages.vercel
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
      rustToolchain
      typescript
      typescript-language-server
      yarn
      zig
    ]
    ++ lib.optionals (!isWSLHost) [ alacritty ];

  programs.go.enable = true;
  programs.go.package = pkgs.go;

  home.sessionVariables = {
    RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
  };

  programs.alacritty = lib.mkIf (!isWSLHost) {
    enable = true;

    settings = {
      font = {
        normal = {
          family = "FiraCode Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "FiraCode Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "FiraCode Nerd Font";
          style = "Italic";
        };
        size = 12.0;
      };
    };
  };
}
