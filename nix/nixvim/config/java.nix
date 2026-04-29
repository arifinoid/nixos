{ pkgs, ... }:
{
  plugins = {
    dap = {
      enable = true;
      adapters = {
        java = {
          type = "executable";
          command = "${pkgs.jdk}/bin/java";
          args = [
            "-jar"
            "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar"
          ];
        };
      };
      configurations = {
        java = [
          {
            type = "java";
            request = "launch";
            name = "Launch Spring Boot App";
            projectName = "your-project-name";
            mainClass = "com.example.YourApplication";
            args = "";
            cwd = "\${workspaceFolder}";
            env = {
              SPRING_PROFILES_ACTIVE = "dev";
            };
          }
        ];
      };
    };

    neotree = {
      enable = true;
      filesystem = {
        filteredItems = {
          hideDotfiles = false;
          hideGitignored = false;
        };
      };
    };

    which-key = {
      enable = true;
      registrations = {
        "<leader>j" = "+Java";
        "<leader>jr" = "+Run";
        "<leader>jd" = "+Debug";
      };
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
      action = "<cmd>lua require('jdtls').java_run_app()<CR>";
      options = {
        desc = "Run Java Application";
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

  extraConfigLua = ''
    -- Java specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
        vim.opt_local.expandtab = true
      end,
    })

    -- Spring Boot specific keymaps
    vim.api.nvim_create_autocmd("BufRead", {
      pattern = "*application*.properties",
      callback = function()
        vim.keymap.set("n", "<leader>sp", "<cmd>lua require('jdtls').spring_boot_run()<CR>", { desc = "Spring Boot Run", buffer = true })
      end,
    })
  '';

  extraPlugins = with pkgs.vimPlugins; [
    nvim-dap
    nvim-dap-ui
    nvim-neotest
  ];
}
