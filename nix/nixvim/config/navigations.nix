{
  icons,
  helpers,
  ...
}:

let
  inherit (helpers) mkLuaFun;
  resize.up = mkLuaFun "vim.cmd [[ resize +1 ]] ";
  resize.down = mkLuaFun "vim.cmd [[ resize -1 ]] ";
  resize.left = mkLuaFun "vim.cmd [[ vertical resize -1 ]] ";
  resize.right = mkLuaFun "vim.cmd [[ vertical resize +1 ]] ";
in
{
  clipboard.register = "unnamed";

  plugins = {
    telescope = {
      enable = true;
      lazyLoad.settings.cmd = "Telescope";
      keymaps.ff.options.desc = "Find by files";
      keymaps.ff.action = "find_files";
      keymaps.fF.options.desc = "Find by words";
      keymaps.fF.action = "live_grep";
      keymaps."f'".options.desc = "Find by String";
      keymaps."f'".action = "grep_string";
      keymaps.fb.options.desc = "Find by current buffers";
      keymaps.fb.action = "buffers";
      keymaps.fB.options.desc = "Find Fuzz by current buffers";
      keymaps.fB.action = "current_buffer_fuzzy_find";
      keymaps.fh.options.desc = "Find by help tags";
      keymaps.fh.action = "help_tags";
      keymaps.fc.options.desc = "Find by Colorscheme";
      keymaps.fc.action = "colorscheme";
      keymaps.fC.options.desc = "Find by highlights";
      keymaps.fC.action = "highlights";
    };

    hop = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.event = "VimEnter";
      };
    };

    which-key.enable = true;
    which-key.settings.spec = [
      {
        __unkeyed-1 = "<c-c>";
        __unkeyed-2 = "<esc>";
        desc = "Escape";
      }
      {
        __unkeyed-1 = "<c-a>";
        __unkeyed-2 = "gg<S-v>G";
        desc = "Select all";
      }

      {
        __unkeyed-1 = "<c-n>";
        __unkeyed-2 = "<cmd>new<cr>";
        desc = "New Buffer Horizontal";
        icon = icons.horizontal;
      }
      {
        __unkeyed-1 = "<c-N>";
        __unkeyed-2 = "<cmd>vnew<cr>";
        desc = "New Buffer Vertical";
        icon = icons.vertical;
      }
      {
        __unkeyed-1 = "<leader>ss";
        __unkeyed-2 = "<cmd>sp<cr>";
        desc = "Split Horizontal";
        icon = icons.horizontal;
      }
      {
        __unkeyed-1 = "<leader>sv";
        __unkeyed-2 = "<cmd>vsp<cr>";
        desc = "Split Vertical";
        icon = icons.vertical;
      }
      {
        __unkeyed-1 = "<c-T>";
        __unkeyed-2 = "<cmd>Telescope<cr>";
        desc = "Open Telescope";
        icon = icons.telescope;
      }
      {
        __unkeyed-1 = "<c-p>";
        __unkeyed-2 = "<cmd>Telescope find_files<cr>";
        desc = "Telescope find files";
        icon = icons.file;
      }
      {
        __unkeyed-1 = "<c-f>";
        __unkeyed-2 = "<cmd>Telescope live_grep<cr>";
        desc = "Telescope grep text";
        icon = icons.telescope;
      }
      {
        __unkeyed-1 = "gb";
        __unkeyed-2 = "<cmd>Telescope git_branches<cr>";
        desc = "Telescope git branches";
        icon = icons.git;
      }
      {
        __unkeyed-1 = "gc";
        __unkeyed-2 = "<cmd>Telescope git_commits<cr>";
        desc = "Telescope git commits";
        icon = icons.git;
      }
      {
        __unkeyed-1 = "gc";
        __unkeyed-2 = "<cmd>Telescope git_status<cr>";
        desc = "Telescope git status";
        icon = icons.git;
      }

      {
        __unkeyed-1 = "<c-s>";
        __unkeyed-2 = "<cmd>w<cr>";
        desc = "Write current buffer";
        icon = icons.save;
      }

      # {
      #   __unkeyed-1 = "<c-S>";
      #   __unkeyed-2 = "<cmd>wq<cr>";
      #   desc = "Write current buffer and quit";
      #   icon = icons.save;
      # }

      {
        __unkeyed-1 = "<c-w>";
        __unkeyed-2 = "<cmd>BufferLinePickClose<cr>";
        desc = "Close current buffer";
        icon = icons.close;
      }
      {
        __unkeyed-1 = "<S-Tab>";
        __unkeyed-2 = "<cmd>BufferLineCyclePrev<cr>";
        desc = "Go to previous buffer";
      }
      {
        __unkeyed-1 = "<Tab>";
        __unkeyed-2 = "<cmd>BufferLineCycleNext<cr>";
        desc = "Go to next buffer";
      }
      {
        __unkeyed-1 = "<c-1>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 1<cr>";
        desc = "Go to buffer 1";
      }
      {
        __unkeyed-1 = "<c-2>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 2<cr>";
        desc = "Go to buffer 2";
      }
      {
        __unkeyed-1 = "<c-3>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 3<cr>";
        desc = "Go to buffer 3";
      }
      {
        __unkeyed-1 = "<c-4>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 4<cr>";
        desc = "Go to buffer 4";
      }
      {
        __unkeyed-1 = "<c-5>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 5<cr>";
        desc = "Go to buffer 5";
      }
      {
        __unkeyed-1 = "<c-6>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 6<cr>";
        desc = "Go to buffer 6";
      }
      {
        __unkeyed-1 = "<c-7>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 7<cr>";
        desc = "Go to buffer 7";
      }
      {
        __unkeyed-1 = "<c-8>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 8<cr>";
        desc = "Go to buffer 8";
      }
      {
        __unkeyed-1 = "<c-9>";
        __unkeyed-2 = "<cmd>BufferLineGoToBuffer 9<cr>";
        desc = "Go to buffer 9";
      }
      {
        __unkeyed-1 = "<c-0>";
        __unkeyed-2 = "<cmd>BufferLast<cr>";
        desc = "Go to last buffer";
      }
      

      {
        __unkeyed-1 = "Y";
        __unkeyed-2 = "\"+yy";
        desc = "Copy to Clipboard!";
        icon = icons.clipboard;
      }

      {
        __unkeyed-1 = "p";
        __unkeyed-2 = "\"+p";
        desc = "Paste from Clipboard";
        icon = icons.paste;
      }

      {
        __unkeyed-1 = "<c-d>";
        __unkeyed-2 = "<c-d>zz";
        desc = "Move top";
        icon = icons.top;
      }

      {
        __unkeyed-1 = "<c-u>";
        __unkeyed-2 = "<c-u>zz";
        desc = "Move down";
        icon = icons.bottom;
      }

      {
        __unkeyed-1 = "<c-k>";
        __unkeyed-2 = "<c-w>k";
        desc = "Move left";
        icon = icons.left;
      }

      {
        __unkeyed-1 = "<c-l>";
        __unkeyed-2 = "<c-w>l";
        desc = "Move right";
        icon = icons.right;
      }

      {
        __unkeyed-1 = "fw";
        __unkeyed-2 = "<cmd>HopWord<cr>";
        desc = "Find by Word";
      }

      {
        __unkeyed-1 = "fhh";
        __unkeyed-2 = "<cmd>HopPattern<cr>";
        desc = "Find by Patterns";
      }

      {
        __unkeyed-1 = "<up>";
        __unkeyed-2.__raw = resize.up;
        desc = "resize window up";
      }

      {
        __unkeyed-1 = "<down>";
        __unkeyed-2.__raw = resize.down;
        desc = "resize window down";
      }

      {
        __unkeyed-1 = "<left>";
        __unkeyed-2.__raw = resize.left;
        desc = "resize window right";
      }

      {
        __unkeyed-1 = "<right>";
        __unkeyed-2.__raw = resize.right;
        desc = "resize window left";
      }

    ];
  };
}