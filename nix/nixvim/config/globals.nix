let
  indent = 4;
in
{
  config = {
    colorscheme = "catppuccin";
    colorschemes.catppuccin.enable = true;
    performance = {
      byteCompileLua = {
        enable = true;
        nvimRuntime = true;
        configs = true;
        plugins = true;
      };
    };
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };
    globals.mapleader = " ";
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

      # Enable relative line numbers
      number = true;
      relativenumber = true;

      # Set tabs to 4 spaces
      tabstop = indent;
      softtabstop = indent;
      showtabline = 2;
      expandtab = true;

      # Enable auto indenting and set it to spaces
      smartindent = true;
      shiftwidth = indent;
      autoindent = true;

      # Enable smart indenting (see https://stackoverflow.com/questions/1204149/smart-wrap-in-vim)
      breakindent = true;

      # Enable incremental searching
      hlsearch = false;
      incsearch = true;

      # Enable text wrap
      wrap = false;

      # Better splitting
      splitbelow = true;
      splitright = true;

      # Enable mouse mode
      mouse = "a";

      # Enable ignorecase + smartcase for better searching
      ignorecase = true;
      smartcase = true; # Don't ignore case with capitals
      grepprg = "rg --vimgrep";
      grepformat = "%f:%l:%c:%m";

      # Decrease updatetime
      updatetime = 50; # faster completion (4000ms default)

      # Set completeopt to have a better completion experience
      completeopt = [
        "menuone"
        "noselect"
        "noinsert"
      ]; # mostly just for cmp

      # Enable persistent undo history
      swapfile = false;
      autoread = true;
      backup = false;
      writebackup = false;
      undofile = true;
      undodir = "~/.vim/undodir";

      # Enable 24-bit colors
      termguicolors = true;

      # Enable the sign column to prevent the screen from jumping
      signcolumn = "yes";

      # Enable cursor line highlight
      cursorline = true; # Highlight the line where the cursor is located

      # Set fold settings
      # These options were recommended by nvim-ufo
      # See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
      foldmethod = "indent";

      # Always keep 8 lines above/below cursor unless at start/end of file
      scrolloff = 8;

      # Place a column line
      colorcolumn = "80";

      # Reduce which-key timeout to 10ms
      timeoutlen = 100;

      # Set encoding type
      encoding = "utf-8";
      fileencoding = "utf-8";

      # More space in the neovim command line for displaying messages
      cmdheight = 1;

      # We don't need to see things like INSERT anymore
      showmode = false;

      # Additional options from Lua config
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
