let
  indent = 4;
in
{
  config = {
    performance = {
      # combinePlugins DINONAKTIFKAN: eksperimental + tabrakan file massal
      # (doc/recipes.md di blink/conform/oil/..., queries/*.scm di treesitter/snacks).
      combinePlugins.enable = false;
      byteCompileLua = {
        enable = true;
        nvimRuntime = true;
        configs = true;
        plugins = true;
      };
    };
    globals.mapleader = " ";
    clipboard.register = "unnamedplus";
    opts = {
      backspace = [
        "indent"
        "eol"
        "start"
      ];
      background = "dark";
      smarttab = true;
      laststatus = 2;
      compatible = false;
      conceallevel = 2;
      concealcursor = "n";

      number = true;
      relativenumber = true;

      tabstop = indent;
      softtabstop = indent;
      showtabline = 2;
      expandtab = true;

      smartindent = true;
      shiftwidth = indent;
      autoindent = true;

      breakindent = true;

      hlsearch = false;
      incsearch = true;

      wrap = false;

      splitbelow = true;
      splitright = true;

      mouse = "a";

      ignorecase = true;
      smartcase = true;
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      updatetime = 50;

      completeopt = [
        "menuone"
        "noselect"
        "noinsert"
      ];

      swapfile = false;
      autoread = true;
      backup = false;
      writebackup = false;
      undofile = true;
      undodir = {
        __raw = "vim.fn.expand('~/.vim/undodir')";
      };

      termguicolors = true;

      signcolumn = "yes";

      cursorline = true;

      scrolloff = 8;

      colorcolumn = "80";

      timeoutlen = 100;

      encoding = "utf-8";
      fileencoding = "utf-8";

      cmdheight = 1;

      showmode = false;

      winblend = 0;
      wildoptions = "pum";
      pumblend = 5;
      isfname = "@-@";
      shortmess = "c";
      hidden = true;
      whichwrap = "b,s,<,>,[,],h,l";
      pumheight = 8;
      sidescrolloff = 5;
      path = "**";
      formatoptions = "r";
    };
  };
}
