{
  pkgs,
  lib,
  icons,
  helpers,
  config,
  ...
}:

rec {
  autoCmd = [
    {
      # Disable cmp in neorepl
      event = [ "FileType" ];
      pattern = "neorepl";
      callback.__raw =
        helpers.mkLuaFun # lua
          ''
            require("cmp").setup.buffer { enabled = false }
          '';
    }
  ];

  extraPlugins = [
    pkgs.vimPlugins.claude-code-nvim
  ];

  plugins = {
    lz-n.plugins = [
      {
        __unkeyed-1 = pkgs.vimPlugins.claude-code-nvim.name;
        cmd = [
          "ClaudeCode"
          "ClaudeCodeFocus"
          "ClaudeCodeDiffDeny"
          "ClaudeCodeDiffAccept"
        ];
      }
    ];
    claude-code = {
      enable = false;
      settings.window = {
        position = "rightbelow vsplit";
        split_ratio = 0.45;
      };
      lazyLoad.enable = true;
      lazyLoad.settings.cmd = [
        "ClaudeCode"
        "ClaudeCodeContinue"
        "ClaudeCodeResume"
        "ClaudeCodeVerbose"
      ];
    };
    avante = {
      enable = true;
      lazyLoad.enable = false;
      settings = {
        provider = "local-qwen";

        diff = {
          autojump = true;
          debug = false;
          list_opener = "copen";
        };

        highlights = {
          diff = {
            current = "GitConflictAncestor";
            incoming = "GitConflictIncoming";
          };
        };

        hints = {
          enabled = true;
        };

        providers = rec {
          openai = {
            api_key_name = "OPENAI_API_KEY";
            model = "gpt-4";
            temperature = 0.3;
            max_tokens = 20000;
          };
          anthropic = {
            api_key_name = "ANTHROPIC_API_KEY";
            model = "claude-3.5-sonnet";
            temperature = 0.3;
            max_tokens = 20000;
          };
          local-qwen = {
            api_key_name = "";
            __inherited_from = "openai";
            endpoint = "http://localhost:11434/v1";
            model = "qwen2.5-coder";
            temperature = 0;
            max_tokens = 4096;
          };
        };
      };
    };

    which-key.settings.spec = [
      {
        __unkeyed-1 = "ta";
        __unkeyed-2 = "<cmd>AvanteToggle<cr>";
        icon = icons.robotFace;
        desc = "Toggle Avante";
      }
      {
        __unkeyed-1 = "<leader>ca";
        __unkeyed-2 = "<cmd>AvanteAsk<cr>";
        icon = icons.robotFace;
        desc = "Open AI Ask";
      }

      {
        __unkeyed-1 = "<leader>cc";
        __unkeyed-2 = "<cmd>AvanteChat<cr>";
        icon = icons.robotFace;
        desc = "Open AI Chat";
      }

      {
        __unkeyed-1 = "<leader>ce";
        __unkeyed-2 = "<cmd>AvanteEdit<cr>";
        icon = icons.robotFace;
        desc = "Edit with instruction";
      }
    ];
  };
}