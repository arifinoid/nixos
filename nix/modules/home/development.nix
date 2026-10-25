{
  pkgs,
  osConfig,
  lib,
  inputs,
  ...
}:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  npmCli = pkgs.callPackage "${inputs.self}/nix/packages/npm-cli.nix" { };
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src"
      "rust-analyzer"
    ];
  };
in
{
  imports = [ inputs.omp.homeManagerModules.default ];

  xdg.configFile."opencode/opencode.json".source = "${inputs.self}/.config/opencode/opencode.json";
  home.file.".claude/settings.json".source = "${inputs.self}/.config/claude/settings.json";
  home.file.".omp/agent/models.yml".source = "${inputs.self}/.config/omp/agent/models.yml";

  home.activation.wakatimeCfg = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    WKEY=$(cat ${osConfig.sops.secrets.wakatime_api_key.path})
    umask 077
    printf '[settings]\napi_key = %s\n' "$WKEY" > "$HOME/.wakatime.cfg"
  '';

  home.packages =
    with pkgs;
    [
      npmCli.pi
      npmCli."9router"
      npmCli.omo
      npmCli.rea
      bun
      unstablePkgs.claude-code
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
      inputs.herdr.packages.${pkgs.system}.default
      jq
      k9s
      lua5_4_compat
      meson
      minikube
      nixfmt-classic
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      unstablePkgs.opencode
      openssl.dev
      pgsync
      pkg-config
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
      # tauri deps
      at-spi2-atk.dev
      atk.dev
      cairo.dev
      dbus.dev
      gdk-pixbuf.dev
      glib.dev
      gobject-introspection
      gobject-introspection.dev
      gtk3.dev
      harfbuzz.dev
      librsvg.dev
      libsoup_3.dev
      pango.dev
      webkitgtk_4_1.dev
      zlib
      zlib.dev
      typescript
      typescript-language-server
      yarn
      zig
    ]
    ++ lib.optionals (!isWSLHost) [ alacritty ];

  programs.go.enable = true;
  programs.go.package = pkgs.go;

  programs.omp.enable = true;
  programs.omp.package = inputs.omp.packages.${pkgs.system}.default.overrideAttrs (old: {
    buildPhase =
      lib.replaceStrings
        [ ''echo "Compiling OMP"'' ]
        [
          ''
            for addon in packages/natives/native/*.node; do
              bun scripts/stamp-native-version.ts "$addon"
            done
            echo "Compiling OMP"
          ''
        ]
        old.buildPhase;
  });

  home.sessionVariables = {
    RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
  };

  programs.fish.shellInit =
    let
      pkgConfigPath = lib.makeSearchPath "lib/pkgconfig" [
        pkgs.glib.dev
        pkgs.gtk3.dev
        pkgs.webkitgtk_4_1.dev
        pkgs.libsoup_3.dev
        pkgs.openssl.dev
        pkgs.pango.dev
        pkgs.cairo.dev
        pkgs.gdk-pixbuf.dev
        pkgs.librsvg.dev
        pkgs.atk.dev
        pkgs.at-spi2-atk.dev
        pkgs.dbus.dev
        pkgs.gobject-introspection.dev
        pkgs.harfbuzz.dev
        pkgs.zlib.dev
      ];
    in
    ''


      set -gx PKG_CONFIG_PATH "${pkgConfigPath}" $PKG_CONFIG_PATH
      set -gx LIBRARY_PATH "${lib.makeLibraryPath [ pkgs.zlib ]}" $LIBRARY_PATH
    '';

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
