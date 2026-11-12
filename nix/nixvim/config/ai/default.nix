{
  icons,
  helpers,
  ...
}:

let
  readLua = p: builtins.readFile p;
in
rec {
  autoCmd = [
    {
      # Define missing Avante sign to avoid "Unknown sign" error
      event = [ "VimEnter" ];
      callback.__raw = helpers.mkLuaFun (readLua ./avante_sign.lua);
    }
  ];

  plugins = {
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
        # default: ollama (deepseek-r1:1.5b via local Ollama).
        # Bisa switch ke "copilot"/"groq"/"grok"/"claude" kalau dibutuhkan.
        provider = "ollama";
        # "agentic" (default) menyuntik prompt tool-use ~10k token; di CPU
        # itu puluhan detik cuma untuk prompt eval. "legacy" lebih ringan.
        mode = "legacy";
        # Prompt bawaan Avante masih menyisakan instruksi tool-use. Model
        # 1.5B di CPU tidak sanggup tool-calling, jadi tegas dinonaktifkan.
        system_prompt = ''
          There are NO tools available in this session. Ignore every tool-use
          instruction above; never output <tool_use> blocks.
          Answer the user's question directly, concisely, in the same language
          they use. For code changes, use *SEARCH/REPLACE* blocks.
        '';

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

        claude.api_key_name = "ANTHROPIC_API_KEY";
        claude.endpoint = "https://api.anthropic.com";
        claude.model = "claude-3-7-sonnet-20250219";
        claude.temperature = 0.7;
        claude.max_tokens = 20000;

        copilot.model = "claude-3.5-sonnet";
        copilot.temperature = 0.3;
        copilot.max_tokens = 20000;

        providers = rec {
          # CPU-only WSL: model load bisa 20-40 detik, jadi timeout default
          # Avante (30 detik) selalu kehabisan waktu -> balasan tidak muncul.
          ollama = {
            endpoint = "http://127.0.0.1:11434";
            model = "deepseek-r1:1.5b";
            timeout = 180000;
            # Model 1.5B di CPU tidak sanggup tool-calling; definisi tool juga
            # menambah prompt puluhan ribu karakter.
            disable_tools = true;
            extra_request_body = {
              keep_alive = "30m";
              # deepseek-r1 default-nya "thinking"; di CPU itu lambat banget.
              think = false;
              options = {
                # Prompt Avante (legacy, tool dimatikan) ~2.5k token. 8192
                # cukup untuk prompt + output + file context, dan tidak
                # memaksa reload model sesering 32768.
                num_ctx = 8192;
                num_predict = 512;
                temperature = 0.4;
              };
            };
          };
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
    # copilot disalurkan via blink-cmp-copilot (lihat lsp.nix), bukan cmp

    minuet = {
      enable = true;
      settings = {
        provider = "openai_fim_compatible";
        n_completions = 1;
        # Context kecil = prompt eval cepat di CPU.
        context_window = 512;
        # Default 3 detik: terlalu pendek untuk model lokal di CPU,
        # request di-cancel sebelum Ollama selesai -> seolah "tidak respon".
        request_timeout = 20;
        debounce = 300;
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM";
            name = "Ollama";
            end_point = "http://127.0.0.1:11434/v1/completions";
            model = "qwen2.5-coder:1.5b";
            stream = true;
            optional = {
              max_tokens = 96;
              top_p = 0.9;
              temperature = 0.2;
            };
          };
        };
        virtualtext = {
          # Default Minuet kosong = tidak pernah auto-trigger.
          # "*" = aktif di semua filetype, lalu kecualikan buffer besar/UI.
          auto_trigger_ft = [ "*" ];
          auto_trigger_ignore_ft = [
            "oil"
            "NvimTree"
            "neo-tree"
            "TelescopePrompt"
            "Avante"
            "AvanteInput"
            "markdown"
          ];
          keymap = {
            # Di terminal <A-A> dan <A-a> sama-sama terkirim sebagai Alt+a,
            # jadi accept utuh dipasang di <A-a>.
            accept = "<A-a>";
            accept_line = "<A-l>";
            accept_n_lines = "<A-z>";
            prev = "<A-[>";
            next = "<A-]>";
            dismiss = "<A-e>";
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
      {
        __unkeyed-1 = "<leader>cpo";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('openai')<cr>";
        icon = icons.robotFace;
        desc = "Provider: OpenAI";
      }
      {
        __unkeyed-1 = "<leader>cpa";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('claude')<cr>";
        icon = icons.robotFace;
        desc = "Provider: Anthropic";
      }
      {
        __unkeyed-1 = "<leader>cpg";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('groq')<cr>";
        icon = icons.robotFace;
        desc = "Provider: Groq";
      }
      {
        __unkeyed-1 = "<leader>cpd";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('deepseek')<cr>";
        icon = icons.robotFace;
        desc = "Provider: DeepSeek";
      }
      {
        __unkeyed-1 = "<leader>cpc";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('copilot')<cr>";
        icon = icons.robotFace;
        desc = "Provider: Copilot";
      }
      {
        __unkeyed-1 = "<leader>cpl";
        __unkeyed-2 = "<cmd>lua require('avante.api').switch_provider('ollama')<cr>";
        icon = icons.robotFace;
        desc = "Provider: Ollama (DeepSeek-R1)";
      }
      {
        __unkeyed-1 = "<leader>cmt";
        __unkeyed-2 = "<cmd>Minuet virtualtext toggle<cr>";
        icon = icons.robotFace;
        desc = "Minuet: Toggle Virtualtext";
      }
      {
        __unkeyed-1 = "<leader>cmb";
        __unkeyed-2 = "<cmd>Minuet blink toggle<cr>";
        icon = icons.robotFace;
        desc = "Minuet: Toggle Blink Auto-cmp";
      }
    ];
  };
}
