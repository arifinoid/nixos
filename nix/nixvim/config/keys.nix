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

    # Buffer management
    {
      key = "<S-Tab>";
      mode = "n";
      action = "<Cmd>BufferPrevious<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Previous buffer";
      };
    }
    {
      key = "<Tab>";
      mode = "n";
      action = "<Cmd>BufferNext<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Next buffer";
      };
    }
    {
      key = "<C-1>";
      mode = "n";
      action = "<Cmd>BufferGoto 1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 1";
      };
    }
    {
      key = "<C-2>";
      mode = "n";
      action = "<Cmd>BufferGoto 2<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 2";
      };
    }
    {
      key = "<C-3>";
      mode = "n";
      action = "<Cmd>BufferGoto 3<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 3";
      };
    }
    {
      key = "<C-4>";
      mode = "n";
      action = "<Cmd>BufferGoto 4<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 4";
      };
    }
    {
      key = "<C-5>";
      mode = "n";
      action = "<Cmd>BufferGoto 5<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 5";
      };
    }
    {
      key = "<C-6>";
      mode = "n";
      action = "<Cmd>BufferGoto 6<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 6";
      };
    }
    {
      key = "<C-7>";
      mode = "n";
      action = "<Cmd>BufferGoto 7<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 7";
      };
    }
    {
      key = "<C-8>";
      mode = "n";
      action = "<Cmd>BufferGoto 8<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 8";
      };
    }
    {
      key = "<C-9>";
      mode = "n";
      action = "<Cmd>BufferGoto 9<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to buffer 9";
      };
    }
    {
      key = "<C-0>";
      mode = "n";
      action = "<Cmd>BufferLast<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Go to last buffer";
      };
    }
    {
      key = "<C-w>";
      mode = "n";
      action = "<Cmd>BufferClose<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Close buffer";
      };
    }
    {
      key = "<S-p>";
      mode = "n";
      action = "<Cmd>BufferPick<CR>";
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
    {
      key = "<C-m>";
      mode = "n";
      action = ":Magit<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Open Magit";
      };
    }
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
      key = "<C-w>";
      mode = "n";
      action = ":bdelete<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Delete buffer";
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

    # Text manipulation
    {
      key = "<J>";
      mode = "n";
      action = ":m .+1<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Move line down";
      };
    }
    {
      key = "<K>";
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

    # Obsidian keymaps
    {
      key = "<leader>oc";
      mode = "n";
      action = "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Obsidian toggle checkbox";
      };
    }
    {
      key = "<leader>ot";
      mode = "n";
      action = "<cmd>ObsidianTemplate<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Insert Obsidian template";
      };
    }
    {
      key = "<leader>oo";
      mode = "n";
      action = "<cmd>ObsidianOpen<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Open in Obsidian App";
      };
    }
    {
      key = "<leader>ob";
      mode = "n";
      action = "<cmd>ObsidianBacklinks<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Show Obsidian Backlinks";
      };
    }
    {
      key = "<leader>ol";
      mode = "n";
      action = "<cmd>ObsidianLinks<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Show Obsidian Links";
      };
    }
    {
      key = "<leader>on";
      mode = "n";
      action = "<cmd>ObsidianNew<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Create New Note";
      };
    }
    {
      key = "<leader>os";
      mode = "n";
      action = "<cmd>ObsidianSearch<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Search Note";
      };
    }
    {
      key = "<leader>oq";
      mode = "n";
      action = "<cmd>ObsidianQuickSwitch<CR>";
      options = {
        silent = true;
        noremap = true;
        desc = "Quick Switch";
      };
    }

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
