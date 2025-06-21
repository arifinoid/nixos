{
  plugins = {
    cmp = {
      enable = true;
    };
    lsp-format = {
      enable = true;
      settings = {
        gopls = {
          exclude = [
            "gopls"
          ];
          force = true;
          order = [
            "gopls"
            "efm"
          ];
          sync = true;
        };
      };
    };
    lsp = {
      enable = true;
      inlayHints = true;
      servers = {
        dockerls = {
          enable = true;
        };
        html = {
          enable = true;
        };
        jsonls = {
          enable = true;
        };
        lua_ls = {
          enable = true;
        };
        nixd = {
          enable = true;
        };
        markdown_oxide = {
          enable = true;
        };
        terraformls = {
          enable = true;
        };
        yamlls = {
          enable = true;
        };
        gopls = {
          enable = true;
        };
        pyright = {
          enable = true;
        };
        marksman = {
          enable = true;
        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          gd = {
            action = "definition";
            desc = "Goto Definition";
          };
          gr = {
            action = "references";
            desc = "Goto References";
          };
          gD = {
            action = "declaration";
            desc = "Goto Declaration";
          };
          gI = {
            action = "implementation";
            desc = "Goto Implementation";
          };
          gT = {
            action = "type_definition";
            desc = "Type Definition";
          };
          "<leader>cr" = {
            action = "rename";
            desc = "Rename";
          };
        };
      };

      onAttach = ''
        function onAttach(client, bufnr)
          local signature_ok, signature = pcall(require, "lsp_signature")
          if signature_ok then
            local signature_config = {
              bind = true,
              doc_lines = 0,
              floating_window = true,
              fix_pos = true,
              hint_enable = true,
              hint_prefix = " ",
              hint_scheme = "String",
              hi_parameter = "Search",
              max_height = 22,
              max_width = 120,      -- max_width of signature floating_window, line will be wrapped if exceed max_width
              handler_opts = {
                border = "rounded", -- double, single, shadow, none
              },
              zindex = 200,         -- by default it will be on top of all floating windows, set to 50 send it to bottom
              padding = "",         -- character to pad on left and right of signature can be ' ', or '|'  etc
            }
            signature.on_attach(signature_config, bufnr)
          end

          require('lsp-inlayhints').on_attach(client, bufnr, false)
        end
      '';
    };

    lspkind.enable = true;
    lspkind.cmp.enable = true;
    lspsaga = {
      enable = true;
      lightbulb.sign = false;
      lightbulb.virtualText = true;
      lightbulb.debounce = 40;
      ui.codeAction = "⛭";
    };
  };
}
