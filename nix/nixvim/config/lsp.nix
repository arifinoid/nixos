{ pkgs, ... }:
{
  plugins.lsp = {
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cmake.enable = true;
      cssls.enable = true;
      gopls.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      nixd.enable = true;
      prismals.enable = true;
      ruff.enable = true;
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
      ts_ls.enable = true;
      yamlls.enable = true;
      zls.enable = true;
    };
  };
  extraPlugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    typescript-tools-nvim
  ];
  extraConfigLua =
    # lua
    ''
      -- Extra nvim-lspconfig configuration
      -- Common LSP key mappings
      local function set_cmn_lsp_keybinds()
      	local lsp_keybinds = {
      		{
      			key = "K",
      			action = vim.lsp.buf.hover,
      			options = {
      				buffer = 0,
      				desc = "hover [K]noledge with LSP",
      			},
      		},
      		{
      			key = "gd",
      			action = vim.lsp.buf.definition,
      			options = {
      				buffer = 0,
      				desc = "[g]o to [d]efinition with LSP",
      			},
      		},
      		{
      			key = "gy",
      			action = vim.lsp.buf.type_definition,
      			options = {
      				buffer = 0,
      				desc = "[g]o to t[y]pe definition with LSP",
      			},
      		},
      		{
      			key = "gi",
      			action = vim.lsp.buf.implementation,
      			options = {
      				buffer = 0,
      				desc = "[g]o to [i]mplementation with LSP",
      			},
      		},
      		{
      			key = "<leader>dj",
      			action = vim.diagnostic.goto_next,
      			options = {
      				buffer = 0,
      				desc = "Go to next [d]iagnostic with LSP",
      			},
      		},
      		{
      			key = "<leader>dk",
      			action = vim.diagnostic.goto_prev,
      			options = {
      				buffer = 0,
      				desc = "Go to previous [d]iagnostic with LSP",
      			},
      		},
      		{
      			key = "<leader>r",
      			action = vim.lsp.buf.rename,
      			options = {
      				buffer = 0,
      				desc = "[r]ename variable with LSP",
      			},
      		},
      	}

      	for _, bind in ipairs(lsp_keybinds) do
      		vim.keymap.set("n", bind.key, bind.action, bind.options)
      	end
      end

      -- Additional lsp-config
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Individual LSP configs
      -- asm LSP
      require("lspconfig").asm_lsp.setup({
      	capabilities = capabilities,
      	filetypes = { "asm" },

      	-- Fix for missing root dir
      	root_dir = function(fname)
      		return vim.loop.cwd()
      	end,
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Bash LSP
      require("lspconfig").bashls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- clang LSP
      require("lspconfig").clangd.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- cmake LSP
      require("lspconfig").cmake.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- CSS LSP
      require("lspconfig").cssls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- golang lsp
      require("lspconfig").gopls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- HTML lsp
      require("lspconfig").html.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- JSON lsp
      require("lspconfig").jsonls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Lua LSP
      require("lspconfig").lua_ls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Markdown LSP
      require("lspconfig").marksman.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Nix LSP
      require("lspconfig").nixd.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      	settings = {
      		nixd = {
      			formatting = {
      				command = { "nixfmt" },
      			},
      		},
      	},
      })

      -- Prisma LSP
      require("lspconfig").prismals.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Python LSP
      require("lspconfig").ruff.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Rust LSP
      require("lspconfig").rust_analyzer.setup({
      	root_dir = function(fname)
      		return vim.loop.cwd()
      	end,
      	settings = {
      		['rust-analyzer'] = {
      			cargo = {
      				allFeatures = true,
      			},
      		},
      	},
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      -- Typescript/Javascript LSP
      require("lspconfig").ts_ls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })

      require("typescript-tools").setup {
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      	settings = {
      		-- spawn additional tsserver instance to calculate diagnostics on it
      		separate_diagnostic_server = true,
      		-- "change"|"insert_leave" determine when the client asks the server about diagnostic
      		-- via the `workspace/diagnostic/refresh` request
      		-- set to "insert_leave" to reduce the number of client server interaction
      		diagnostic_messages_enabled = true,
      		-- enable/disable the "no @types packages found" diagnostic
      		no_suggestions = false,
      		-- by default code lenses are displayed on all referencable values and for some of you it can
      		-- be too much this option reduce count of them by removing member references from lenses
      		disable_member_code_lens = true,
      		-- JSXCloseTag
      		-- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
      		-- that maybe have a conflict if enable this feature. )
      		jsx_close_tag = {
      			enable = false,
      			filetypes = { "javascriptreact", "typescriptreact" },
      		}
      	},
      }

      -- YAML LSP
      require("lspconfig").yamlls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })
      -- Zig LSP
      require("lspconfig").zls.setup({
      	on_attach = function()
      		set_cmn_lsp_keybinds()
      	end,
      })
    '';
}
