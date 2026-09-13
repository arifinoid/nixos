{
  helpers,
  icons,
  pkgs,
  ...
}:
let
  readLua = p: builtins.readFile p;
in
{
  colorscheme = "catppuccin";
  colorschemes.catppuccin.enable = true;

  opts = {
    list = false;
    listchars = "nbsp:+,tab:${icons.tab} ,trail:-";
  };

  extraConfigLuaPre = readLua ./term_gui_color.lua;

  autoCmd = [
    {
      event = [ "User" ];
      pattern = "LspProgressStatusUpdated";
      callback.__raw = helpers.mkLuaFun (readLua ./lualine_refresh.lua);
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    # theme
    catppuccin-nvim
    midnight-nvim

    # extra
    unicode-vim
    lsp-progress-nvim
    oil-nvim
  ];

  extraConfigLua = ''
    require("oil").setup({
      columns = { "icon", "permissions", "size", "mtime" },
      delete_to_trash = true,
      view_options = {
        show_hidden = true,
      },
    })
  '';

  userCommands.StatusLine.desc = "Toggle Status Line";
  userCommands.StatusLine.command.__raw = helpers.mkLuaFun (readLua ./lualine_hide.lua);

  plugins = rec {
    # lazy load management
    lz-n = {
      enable = true;
      plugins = [
        {
          __unkeyed-1 = "unicode.vim";
          cmd = [
            "Digraphs"
            "DigraphsNew"
            "UnicodeNew"
            "UnicodeSearch"
            "UnicodeTable"
            "UnicodeCache"
          ];
        }
        {
          __unkeyed-1 = "oil.nvim";
          cmd = [ "Oil" ];
        }
        {
          __unkeyed-1 = "typr";
          cmd = [
            "Typr"
            "TyprStats"
          ];
        }
      ];
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "<c-b>";
        __unkeyed-2 = "<cmd>Oil<CR>";
        desc = "Open file browser";
      }

      {
        __unkeyed-1 = "ts";
        __unkeyed-2 = "<cmd>StatusLine<cr>";
        desc = "Toggle Status Line";
      }

      {
        __unkeyed-1 = "ti";
        __unkeyed-2 = "<cmd>IBLToggle<cr>";
        desc = "Toggle Indent Blankline";
      }

      {
        __unkeyed-1 = "tc";
        __unkeyed-2 = "<cmd>ColorizerToggle<cr>";
        desc = "Toggle Colorizer";
      }
    ];

    wakatime.enable = true;
    wakatime.autoLoad = true;

    presence-nvim = { };

    colorizer = {
      enable = true;
      lazyLoad.settings.cmd = [ "ColorizerToggle" ];
      settings = {
        user_default_options = {
          mode = "virtualtext";
          virtualtext = " ■";
          RRGGBBAA = true;
          RRGGBB = true;
          AARRGGBB = true;
        };
      };
    };

    cursorline.enable = true;

    rainbow-delimiters = {
      enable = true;
      # highlight = indent-blankline.settings.scope.highlight;
    };

    indent-blankline = {
      enable = true;
      settings.indent.char = "";
      settings.scope.enabled = true;
      settings.scope.char = icons.indent;
      settings.whitespace.highlight = [ "Whitespace" ];
      settings.exclude.buftypes = [
        "nofile"
        "terminal"
        "neorg"
      ];
      settings.exclude.filetypes = [
        "norg"
        "oil"
        "sagaoutline"
        "help"
        "terminal"
        "dashboard"
        "lspinfo"
        "TelescopePrompt"
        "TelescopeResults"
      ];
    };

    web-devicons = {
      enable = true;
      customIcons = {
        norg = {
          icon = icons.language.org;
          color = "#389EDD";
          cterm_color = "65";
          name = "Norg";
        };
      };
    };

    lualine = {
      enable = true;
      lazyLoad.settings.event = "BufEnter";
      lazyLoad.settings.cmd = [ "StatusLine" ];
      lazyLoad.settings.before.__raw = ''


        require('lsp-progress').setup()
      '';
      settings.theme = "catppuccin";
      settings.options.disabled_filetypes.__unkeyed-1 = "oil";
      settings.options.disabled_filetypes.statusline = [
        "sagaoutline"
        "Trouble"
      ];
      settings.options.component_separators.left = "";
      settings.options.component_separators.right = "";
      settings.options.section_separators.left = icons.circleRight;
      settings.options.section_separators.right = icons.circleLeft;
      settings.sections.lualine_a = [
        {
          __unkeyed-1 = "mode";
          separator.right = icons.circleRight;
          padding.left = 1;
        }
      ];
      settings.sections.lualine_b = [
        {
          __unkeyed-1 = "branch";
          color.fg = "BlueSign";
        }
        "diff"
      ];
      settings.sections.lualine_c = [
        "diagnostics"
      ];
      settings.sections.lualine_x = [
        "searchcount"
        "selectioncount"
      ];
      settings.sections.lualine_y = [
        {
          __unkeyed-1.__raw =
            # lua
            ''
              (function()
                local ft = require('lualine.components.filetype'):extend()
                local lsp_progress = require('lsp-progress')

                function ft:update_status()
                  local data = ft.super.update_status(self)
                  return lsp_progress.progress({
                    max_size = 50,
                    format = function(messages)
                        if #messages > 0 then
                            return table.concat(messages, " ")
                        end
                        return data
                    end,
                  })
                end

                return ft
              end)()
            '';
        }
        "progress"
      ];
      settings.sections.lualine_z = [
        {
          __unkeyed-1 = "location";
          separator.left = icons.circleLeft;
          padding.right = 1;
        }
      ];
      settings.winbar = { };
      settings.tabline = { };
      settings.extensions = [ ];
    };

    treesitter = {
      enable = true;
      lazyLoad.enable = true;
      lazyLoad.settings.event = "BufRead";
      settings.indent.enable = true;
      settings.highlight.enable = true;
      grammarPackages =
        builtins.map
          (
            x:
            pkgs.vimPlugins.nvim-treesitter.builtGrammars.${x} or pkgs.tree-sitter-grammars."tree-sitter-${x}"
          )
          [
            # ┌────────────────────────────────────┐
            # │ move to ignoreInstall for disabled │
            # └────────────────────────────────────┘
            "asm"
            "bash"
            "c"
            "cmake"
            "comment"
            "css"
            "dhall"
            "diff"
            "dockerfile"
            "dot"
            "fish"
            "git_config"
            "git_rebase"
            "gitattributes"
            "gitcommit"
            "gitignore"
            "go"
            "gomod"
            "gosum"
            "gotmpl"
            "gpg"
            "graphql"
            "haskell"
            "haskell_persistent"
            "hcl"
            "helm"
            "html"
            "http"
            "javascript"
            "jq"
            "jsdoc"
            "json"
            "latex"
            "lua"
            "luadoc"
            "luap"
            "luau"
            "make"
            "markdown"
            "markdown_inline"
            "mermaid"
            "nix"
            "norg"
            "norg-meta"
            "ocaml"
            "ocaml_interface"
            "ocamllex"
            "passwd"
            "po"
            "proto"
            "pymanifest"
            "python"
            "query"
            "regex"
            "rust"
            "rescript"
            "sql"
            "ssh_config"
            "templ"
            "terraform"
            "textproto"
            "tmux"
            "todotxt"
            "toml"
            "tsx"
            "typescript"
            "vhs"
            "vim"
            "vimdoc"
            "xml"
            "yaml"
          ];
    };

    bufferline = {
      enable = true;
      settings = {
        options = {
          buffer_close_icon = icons.close;
          separator_style = "thin";
        };
      };
    };

    snacks = {
      enable = true;
      settings = {
        bigfile = {
          enabled = true;
        };
        notifier = {
          enabled = true;
          timeout = 3000;
        };
        quickfile = {
          enabled = false;
        };
        statuscolumn = {
          enabled = false;
        };
        words = {
          debounce = 100;
          enabled = true;
        };
      };
    };

    noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "cmp.entry.get_documentation" = true;
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
          };
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          inc_rename = true;
          long_message_to_split = true;
          lsp_doc_border = true;
        };
      };
    };

  };
}
