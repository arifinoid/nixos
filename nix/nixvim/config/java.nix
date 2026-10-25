{ pkgs, ... }:
{
  plugins = {
    dap = {
      enable = true;
      adapters = { };
      configurations = {
        # Launch config diisi otomatis oleh nvim-jdtls (main class picker).
        # Template attach di bawah untuk debug proses yang sudah jalan (-agentlib:jdwp ...=:5005).
        java = [
          {
            type = "java";
            request = "attach";
            name = "Attach to remote (127.0.0.1:5005)";
            hostName = "127.0.0.1";
            port = 5005;
          }
        ];
      };
    };
    dap-ui.enable = true;

    which-key = {
      enable = true;
      settings.spec = [
        {
          __unkeyed-1 = "<leader>j";
          group = "Java";
        }
        {
          __unkeyed-1 = "<leader>jr";
          group = "Run";
        }
        {
          __unkeyed-1 = "<leader>jd";
          group = "Debug";
        }
      ];
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>jc";
      action = "<cmd>lua require('jdtls').compile()<CR>";
      options = {
        desc = "Compile Java";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>jr";
      action = "<cmd>lua require('jdtls.dap').setup_dap_main_class_configs(); require('dap').continue()<CR>";
      options = {
        desc = "Run Java (main class picker)";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>jd";
      action = "<cmd>lua require('dap').continue()<CR>";
      options = {
        desc = "Debug Java Application";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>jbo";
      action = "<cmd>lua require('jdtls').organize_imports()<CR>";
      options = {
        desc = "Organize Imports";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>jbt";
      action = "<cmd>lua require('jdtls').test_class()<CR>";
      options = {
        desc = "Test Class";
        silent = true;
      };
    }
    {
      mode = "n";
      key = "<leader>jbn";
      action = "<cmd>lua require('jdtls').test_nearest_method()<CR>";
      options = {
        desc = "Test Nearest Method";
        silent = true;
      };
    }
  ];

  extraPlugins = with pkgs.vimPlugins; [
    nvim-jdtls
  ];

  extraConfigLua = ''
    
        -- nvim-jdtls attach per-project (ganti lsp.servers.jdtls yang di-disable).
        -- Workspace unik per project di ~/.cache, bukan /tmp shared.
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "java",
          callback = function()
            local jdtls = require("jdtls")
            local root = require("jdtls.setup").find_root(
              { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }
            ) or vim.fn.getcwd()
            local project = vim.fn.fnamemodify(root, ":p:h:t")
            local home = os.getenv("HOME")
            jdtls.start_or_attach({
              cmd = {
                "${pkgs.jdt-language-server}/bin/jdtls",
                "-configuration",
                home .. "/.cache/jdtls/config",
                "-data",
                home .. "/.cache/jdtls/workspace/" .. project,
              },
              root_dir = root,
              capabilities = require("blink-cmp").get_lsp_capabilities(),
            })
            pcall(require("jdtls.dap").setup_dap_main_class_configs)
          end,
        })
    
                -- Java specific settings
                vim.api.nvim_create_autocmd("FileType", {
                  pattern = "java",
                  callback = function()
                    vim.opt_local.shiftwidth = 4
                    vim.opt_local.tabstop = 4
                    vim.opt_local.expandtab = true
                  end,
                })
        
                -- Spring Boot: jalankan/debug via DAP (pilih main class)
                vim.api.nvim_create_autocmd("BufRead", {
                  pattern = "*application*.properties",
                  callback = function()
                    vim.keymap.set("n", "<leader>sp", "<cmd>lua require('jdtls.dap').setup_dap_main_class_configs(); require('dap').continue()<CR>", { desc = "Spring Boot Run (DAP)", buffer = true })
                  end,
                })
  '';
}
