{
  keymaps = [
    {
      key = "<C-c>";
      mode = "i";
      action = "<Esc>";
      options = {
        silent = true;
        noremap = true;
        desc = "Exit insert mode";
      };
    }

    # Buffer management (bufferline.nvim)
    {
      key = "<S-Tab>";
      mode = "n";
      action = "<Cmd>BufferLineCyclePrev<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Previous buffer";
      };
    }
    {
      key = "<Tab>";
      mode = "n";
      action = "<Cmd>BufferLineCycleNext<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Next buffer";
      };
    }
    {
      key = "<C-1>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 1";
      };
    }
    {
      key = "<C-2>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 2<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 2";
      };
    }
    {
      key = "<C-3>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 3<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 3";
      };
    }
    {
      key = "<C-4>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 4<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 4";
      };
    }
    {
      key = "<C-5>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 5<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 5";
      };
    }
    {
      key = "<C-6>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 6<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 6";
      };
    }
    {
      key = "<C-7>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 7<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 7";
      };
    }
    {
      key = "<C-8>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 8<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 8";
      };
    }
    {
      key = "<C-9>";
      mode = "n";
      action = "<Cmd>BufferLineGoToBuffer 9<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 9";
      };
    }
    {
      key = "<C-0>";
      mode = "n";
      action = "<Cmd>b$<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to last buffer";
      };
    }
    {
      key = "<S-p>";
      mode = "n";
      action = "<Cmd>BufferLinePick<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Pick buffer";
      };
    }

    # Window management
    {
      key = "<C-h>";
      mode = "n";
      action = "<C-w>h";
      options = {
        silent = true;
        noremap = true;
        desc = "Move to left window";
      };
    }
    {
      key = "<C-l>";
      mode = "n";
      action = "<C-w>l";
      options = {
        silent = true;
        noremap = true;
        desc = "Move to right window";
      };
    }
    {
      key = "<C-j>";
      mode = "n";
      action = "<C-w>j";
      options = {
        silent = true;
        noremap = true;
        desc = "Move to bottom window";
      };
    }
    {
      key = "<C-k>";
      mode = "n";
      action = "<C-w>k";
      options = {
        silent = true;
        noremap = true;
        desc = "Move to top window";
      };
    }
    # NOTE: <C-m> sengaja tidak di-map (di terminal == Enter).
    # Butuh git UI? enable plugins.neogit dulu, baru tambah keymap.
    {
      key = "ss";
      mode = "n";
      action = ":split<Return><C-w>w";
      options = {
        silent = true;
        noremap = true;
        desc = "Split horizontally";
      };
    }
    {
      key = "sv";
      mode = "n";
      action = ":vsplit<Return><C-w>w";
      options = {
        silent = true;
        noremap = true;
        desc = "Split vertically";
      };
    }

    # LSP keymaps
    {
      key = "gd";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.definition()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to definition";
      };
    }
    {
      key = "gD";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.declaration()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to declaration";
      };
    }
    {
      key = "gr";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.references()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Find references";
      };
    }
    {
      key = "gR";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.rename()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Rename";
      };
    }
    {
      key = "gh";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.signature_help()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Signature help";
      };
    }
    {
      key = "K";
      mode = "n";
      action = "<cmd>lua vim.lsp.buf.hover()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Hover documentation";
      };
    }
    {
      key = "[d";
      mode = "n";
      action = "<cmd>lua vim.diagnostic.goto_prev()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Previous diagnostic";
      };
    }
    {
      key = "]d";
      mode = "n";
      action = "<cmd>lua vim.diagnostic.goto_next()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Next diagnostic";
      };
    }
    {
      key = "<leader>e";
      mode = "n";
      action = "<cmd>lua vim.diagnostic.open_float()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Show diagnostic float";
      };
    }

    # Lspsaga (finder/peek/outline)
    {
      key = "gf";
      mode = "n";
      action = "<cmd>Lspsaga finder<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Saga finder (def/ref/impl)";
      };
    }
    {
      key = "gp";
      mode = "n";
      action = "<cmd>Lspsaga peek_definition<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Saga peek definition";
      };
    }
    {
      key = "<leader>so";
      mode = "n";
      action = "<cmd>Lspsaga outline<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Saga symbols outline";
      };
    }

    # Trouble (diagnostics/symbols)
    {
      key = "<leader>xx";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Trouble workspace diagnostics";
      };
    }
    {
      key = "<leader>xX";
      mode = "n";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Trouble buffer diagnostics";
      };
    }
    {
      key = "<leader>cs";
      mode = "n";
      action = "<cmd>Trouble symbols toggle<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Trouble document symbols";
      };
    }

    # WTF (AI explain diagnostic, butuh API key)
    {
      key = "<leader>wd";
      mode = "n";
      action = "<cmd>Wtf<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Explain diagnostic with AI";
      };
    }

    # Gitsigns (hunk navigation + actions)
    {
      key = "]h";
      mode = "n";
      action = "<cmd>Gitsigns next_hunk<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Next git hunk";
      };
    }
    {
      key = "[h";
      mode = "n";
      action = "<cmd>Gitsigns prev_hunk<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Previous git hunk";
      };
    }
    {
      key = "<leader>hs";
      mode = "n";
      action = "<cmd>Gitsigns stage_hunk<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Stage hunk";
      };
    }
    {
      key = "<leader>hr";
      mode = "n";
      action = "<cmd>Gitsigns reset_hunk<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Reset hunk";
      };
    }
    {
      key = "<leader>hp";
      mode = "n";
      action = "<cmd>Gitsigns preview_hunk<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Preview hunk";
      };
    }
    {
      key = "<leader>hb";
      mode = "n";
      action = "<cmd>Gitsigns blame_line<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Blame line";
      };
    }
    {
      key = "<leader>hd";
      mode = "n";
      action = "<cmd>Gitsigns diffthis<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Diff this buffer";
      };
    }

    # Window resizing
    {
      key = "<Left>";
      mode = "n";
      action = ":vertical resize +1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Increase window width";
      };
    }
    {
      key = "<Right>";
      mode = "n";
      action = ":vertical resize -1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Decrease window width";
      };
    }
    {
      key = "<Up>";
      mode = "n";
      action = ":resize -1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Decrease window height";
      };
    }
    {
      key = "<Down>";
      mode = "n";
      action = ":resize +1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Increase window height";
      };
    }

    # File operations
    {
      key = "<C-b>";
      mode = "n";
      action = "<cmd>Oil<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Open file browser";
      };
    }
    {
      key = "<leader>bd";
      mode = "n";
      action = "<cmd>bdelete<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Delete current buffer";
      };
    }
    {
      key = "<C-q>";
      mode = "n";
      action = ":bufdo bd<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Delete all buffers";
      };
    }
    {
      key = "<C-s>";
      mode = "n";
      action = ":w<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Save file";
      };
    }
    {
      key = "<C-p>";
      mode = "n";
      action = ":Telescope find_files<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Find files";
      };
    }
    {
      key = "<C-f>";
      mode = "n";
      action = ":Telescope live_grep<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Live grep";
      };
    }
    {
      key = "<C-t>";
      mode = "n";
      action = ":tabedit<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "New tab";
      };
    }

    # Git operations
    {
      key = "gb";
      mode = "n";
      action = ":Telescope git_branches<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Git branches";
      };
    }
    {
      key = "gc";
      mode = "n";
      action = ":Telescope git_commits<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Git commits";
      };
    }
    {
      key = "gs";
      mode = "n";
      action = ":Telescope git_status<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Git status";
      };
    }

    # Text manipulation (Alt-based biar K/J standar tetap bebas: K hover, J join)
    {
      key = "<A-j>";
      mode = "n";
      action = ":m .+1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Move line down";
      };
    }
    {
      key = "<A-k>";
      mode = "n";
      action = ":m .-2<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Move line up";
      };
    }
    {
      key = "+";
      mode = "n";
      action = "<C-a>";
      options = {
        silent = true;
        noremap = true;
        desc = "Increment number";
      };
    }
    {
      key = "-";
      mode = "n";
      action = "<C-x>";
      options = {
        silent = true;
        noremap = true;
        desc = "Decrement number";
      };
    }
    {
      key = "<C-z>";
      mode = "n";
      action = ":set foldmethod=expr<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Set fold method to expr";
      };
    }
    {
      key = "<C-x>";
      mode = "n";
      action = ":set foldexpr=nvim_treesitter#foldexpr()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Set fold expr to treesitter";
      };
    }
    {
      key = "<C-a>";
      mode = "n";
      action = "gg<S-v>G";
      options = {
        silent = true;
        noremap = true;
        desc = "Select all";
      };
    }
    {
      key = "te";
      mode = "n";
      action = ":tabedit";
      options = {
        silent = true;
        noremap = true;
        desc = "Tab edit";
      };
    }

    # Visual mode
    {
      key = "<";
      mode = "v";
      action = "<gv";
      options = {
        silent = true;
        noremap = true;
        desc = "Indent left";
      };
    }
    {
      key = ">";
      mode = "v";
      action = ">gv";
      options = {
        silent = true;
        noremap = true;
        desc = "Indent right";
      };
    }

    # Visual block
    {
      key = "J";
      mode = "x";
      action = ":move '>+1<CR>gv-gv";
      options = {
        silent = true;
        noremap = true;
        desc = "Move selection down";
      };
    }
    {
      key = "K";
      mode = "x";
      action = ":move '<-2<CR>gv-gv";
      options = {
        silent = true;
        noremap = true;
        desc = "Move selection up";
      };
    }

    # NOTE: keymap Obsidian dibuang — plugin obsidian-nvim belum di-enable
    # dan ~/Documents/obsidian belum ada. Pasang plugin + workspace dulu kalau mau.

    # Additional utility keymaps
    {
      key = "<leader>s";
      mode = "n";
      action = "[[:%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>]]";
      options = {
        silent = true;
        noremap = true;
        desc = "Replace word under cursor";
      };
    }
    {
      key = "<leader>x";
      mode = "n";
      action = "<cmd>!chmod +x %<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Make file executable";
      };
    }
    {
      key = "<leader>v";
      mode = "n";
      action = ":MarkdownPreviewToggle<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Toggle markdown preview";
      };
    }
  ];
}
