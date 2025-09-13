{
  pkgs,
  lib,
  icons,
  helpers,
  config,
  ...
}:

{
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



  plugins = {
    avante = {
      enable = true;
      settings = {
        provider = "ollama";
        providers = rec {
          ollama = {
            endpoint = "http://localhost:11434/v1";
            model = "qwen2.5-coder:7b";
            temperature = 0.2;
            extra_request_body = {
              options = {
                num_predict = 1024; 
                num_ctx     = 32768;
                keep_alive  = "5m";
                temperature = 0.2;
              };
            };
          };

          deepseek-r1-14b = {
            __inherited_from = "ollama";
            endpoint = "http://localhost:11434/v1";
            model = "deepseek-r1:14b";
            extra_request_body.options = {
              num_predict = 1024;
              num_ctx = 32768;
              keep_alive = "5m";
              temperature = 0.7;
            };
          };

          qianwen = {
            __inherited_from = "ollama";
            endpoint = "http://localhost:11434/v1";
            model = "qwen2.5-coder:7b";
            extra_request_body.options = {
              num_predict = 1024;
              num_ctx = 32768;
              keep_alive = "5m";
              temperature = 0.7;
            };
          };
        };

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
      { __unkeyed-1 = "<leader>cpo"; __unkeyed-2 = "<cmd>AvanteSwitchProvider openai<cr>"; icon = icons.robotFace; desc = "Provider: OpenAI"; }
      { __unkeyed-1 = "<leader>cpa"; __unkeyed-2 = "<cmd>AvanteSwitchProvider anthropic<cr>"; icon = icons.robotFace; desc = "Provider: Anthropic"; }
      { __unkeyed-1 = "<leader>cpg"; __unkeyed-2 = "<cmd>AvanteSwitchProvider groq<cr>"; icon = icons.robotFace; desc = "Provider: Groq"; }
      { __unkeyed-1 = "<leader>cpd"; __unkeyed-2 = "<cmd>AvanteSwitchProvider deepseek<cr>"; icon = icons.robotFace; desc = "Provider: DeepSeek"; }
      { __unkeyed-1 = "<leader>cpl"; __unkeyed-2 = "<cmd>AvanteSwitchProvider ollama<cr>"; icon = icons.robotFace; desc = "Provider: Ollama"; }
    ];
  };
}
