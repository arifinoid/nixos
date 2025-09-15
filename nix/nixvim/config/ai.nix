{
  pkgs,
  lib,
  icons,
  helpers,
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
    {
      # Define missing Avante sign to avoid "Unknown sign" error
      event = [ "VimEnter" ];
      callback.__raw =
        helpers.mkLuaFun # lua
          ''
            local defined = vim.fn.sign_getdefined("AvanteInputPromptSign")
            if not defined or vim.tbl_isempty(defined) then
              vim.fn.sign_define("AvanteInputPromptSign", { text = ">", texthl = "Comment", numhl = "" })
            end
          '';
    }
  ];

  extraPlugins = [
    pkgs.vimPlugins.claude-code-nvim
  ];

  plugins = {
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
      lazyLoad.enable = true;
      lazyLoad.settings.cmd = [
        "AvanteAsk"
        "AvanteBuild"
        "AvanteChat"
        "AvanteEdit"
        "AvanteFocus"
        "AvanteRefresh"
        "AvanteSwitchProvider"
        "AvanteShowRepoMap"
        "AvanteToggle"
      ];
      settings = {
        provider = "ollama";

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

        ollama = {
          endpoint = "http://localhost:11434";
          # model = "qwen2.5-coder"; // for arifinoid host only, wsl-arifinoid is not powerful enough
          model = "qwen2.5-coder:1.5b";
          temperature = 0;
          max_tokens = 4096;
        };

        claude.api_key_name = "ANTHROPIC_API_KEY";
        claude.endpoint = "https://api.anthropic.com";
        claude.model = "claude-3-7-sonnet-20250219";
        claude.temperature = 0.7;
        claude.max_tokens = 20000;

        copilot.model = "claude-3.5-sonnet";
        copilot.temperature = 0.3;
        copilot.max_tokens = 20000;

        providers = rec {
          copilot37 = {
            model = "claude-3.7-sonnet";
            __inherited_from = "copilot";
          };
          grok = groq // {
            api_key_name = "GROK_API_KEY";
            model = "grok-2-latest";
            endpoint = "https://api.x.ai/v1";
          };
          groq = {
            api_key_name = "GROQ_API_KEY";
            __inherited_from = "openai";
            endpoint = "https://api.groq.com/openai/v1";
            model = "llama-3.3-70b-versatile";
            max_tokens = 32768;
          };
        };
      };
    };

    copilot-lua.enable = true;
    copilot-lua.settings.suggestion.enabled = false;
    copilot-lua.settings.panel.enabled = false;

    cmp.settings.sources = lib.optionals plugins.copilot-lua.enable [
      { name = "copilot"; }
    ];

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
      { __unkeyed-1 = "<leader>cpo"; __unkeyed-2 = "<cmd>AvanteSwitchProvider openai<cr>"; icon = icons.robotFace; desc = "Provider: OpenAI"; }
      { __unkeyed-1 = "<leader>cpa"; __unkeyed-2 = "<cmd>AvanteSwitchProvider anthropic<cr>"; icon = icons.robotFace; desc = "Provider: Anthropic"; }
      { __unkeyed-1 = "<leader>cpg"; __unkeyed-2 = "<cmd>AvanteSwitchProvider groq<cr>"; icon = icons.robotFace; desc = "Provider: Groq"; }
      { __unkeyed-1 = "<leader>cpd"; __unkeyed-2 = "<cmd>AvanteSwitchProvider deepseek<cr>"; icon = icons.robotFace; desc = "Provider: DeepSeek"; }
      { __unkeyed-1 = "<leader>cpl"; __unkeyed-2 = "<cmd>AvanteSwitchProvider ollama<cr>"; icon = icons.robotFace; desc = "Provider: Ollama"; }
    ];
  };
}