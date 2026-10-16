{
  pkgs,
  ...
}:
{
  plugins = {
    lsp = {
      enable = true;
      servers = {
        asm_lsp.enable = true;

        bashls.enable = true;

        biome.enable = true;
        biome.autostart = true;

        clangd.enable = true;
        cmake.enable = true;

        cssls.enable = true;

        dockerls.enable = true;

        gopls.enable = true;

        html.enable = true;

        # jdtls dimatikan di sini — di-handle nvim-jdtls di java.nix
        # (workspace per-project + extended capabilities, bukan /tmp shared)
        jdtls.enable = false;

        jsonls.enable = true;

        lua_ls.enable = true;

        marksman.enable = true;

        nixd.enable = true;
        nixd.autostart = true;

        pyright.enable = true;

        ruff.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };

        ts_ls.enable = true;

        terraformls.enable = true;

        yamlls.enable = true;

        zls.enable = true;
      };
    };

    conform-nvim = {
      enable = true;
      settings = {
        formatters = {
          nixfmt = {
            command = "${pkgs.nixfmt}/bin/nixfmt";
            args = [
              "-w"
              "100"
            ];
          };
          stylua = {
            command = "${pkgs.stylua}/bin/stylua";
            args = [
              "--stdin-filepath"
              "$FILENAME"
              "-"
            ];
          };
          ruff_format = {
            command = "${pkgs.ruff}/bin/ruff";
            args = [
              "format"
              "--stdin-filename"
              "$FILENAME"
              "-"
            ];
          };
          biome = {
            command = "${pkgs.biome}/bin/biome";
            args = [
              "check"
              "--write"
              "--stdin-file-path"
              "$FILENAME"
            ];
          };
        };
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          python = [ "ruff_format" ];
          javascript = [ "biome" ];
          javascriptreact = [ "biome" ];
          typescript = [ "biome" ];
          typescriptreact = [ "biome" ];
          json = [ "biome" ];
          jsonc = [ "biome" ];
          # NOTE: css TIDAK ikut — biome 1.9.4 (nixpkgs 25.05) belum support CSS
          # (stabil di Biome 2.x). CSS diformat via lsp_fallback (= tidak ada),
          # jadi save CSS = no-op sampai nixpkgs diupdate.
        };
        format_on_save = {
          timeout_ms = 5000;
          # ft tanpa formatter conform -> pakai LSP (gopls, rust-analyzer, ...)
          lsp_fallback = true;
        };
      };
    };

    lspsaga.enable = true;
    lspsaga.settings.lightbulb.sign = false;
    lspsaga.settings.lightbulb.virtual_text = true;
    lspsaga.settings.lightbulb.debounce = 40;

    luasnip.enable = true;
    luasnip.lazyLoad.settings.event = "InsertEnter";
    friendly-snippets.enable = true;

    trouble.enable = true;
    trouble.lazyLoad.settings.cmd = "Trouble";

    wtf.enable = true;

    gitsigns.enable = true;

    nvim-autopairs.enable = true;
    nvim-autopairs.lazyLoad.settings.event = "InsertEnter";

    blink-cmp-copilot.enable = true;
    blink-emoji.enable = true;

    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;
      settings = {
        # super-tab + navigasi eksplisit: Tab next, S-Tab prev, Enter accept
        keymap = {
          preset = "super-tab";
          "<Tab>" = [
            "select_next"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
        };

        completion = {
          documentation.auto_show = true;
          list.selection = {
            preselect = true;
            auto_insert = true;
          };
        };
        signature.enabled = true;
        appearance = {
          # fallback ke highlight nvim-cmp biar catppuccin tetap cocok
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "normal";
        };
        snippets = {
          expand.__raw = "function(snippet) require('luasnip').lsp_expand(snippet) end";
          active.__raw = "function(filter) local dir = filter and filter.direction or 1 return require('luasnip').jumpable(dir) end";
          jump.__raw = "function(direction) require('luasnip').jump(direction) end";
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
            "copilot"
            "emoji"
          ];
          providers = {
            copilot = {
              async = true;
              module = "blink-cmp-copilot";
              name = "copilot";
              score_offset = 100;
            };
            emoji = {
              module = "blink-emoji";
              name = "Emoji";
              score_offset = 15;
              opts.insert = true;
            };
            lsp.fallbacks = [ ];
            buffer.score_offset = -7;
          };
        };
      };
    };
  };
  # NOTE: typescript-tools-nvim sengaja TIDAK dipasang — rangkap dengan
  # lsp.servers.ts_ls (dua TS server = diagnostik dobel + boros).
  # nvim-lspconfig juga tidak perlu di extraPlugins (sudah dibawa modul lsp).

  diagnostic.settings = {
    virtual_text = {
      prefix = "●";
      spacing = 2;
    };
    signs = true;
    underline = true;
    update_in_insert = false;
    severity_sort = true;
  };
}
