{ lib, helpers, icons, pkgs, ... }:

{
  colorscheme = "catppuccin";

  highlight."@neorg.tags.ranged_verbatim.code_block".link = "Fg";

  opts = {
    list = true;
    listchars = "eol:${icons.eol},nbsp:+,tab:${icons.tab} ,trail:-";

    # --- this fold configurations it depends on treesitter
    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    foldcolumn = "0";
    foldtext = "";
    foldlevel = 99;
    foldlevelstart = 1;
    foldnestmax = 4;
  };

  globals = { elite_mode = 1; };

  extraConfigLuaPre = # lua
    ''
      if vim.fn.has('termguicolors') == 1 then
        vim.opt.termguicolors = true
      end
    '';

  autoCmd = [{
    event = [ "User" ];
    pattern = "LspProgressStatusUpdated";
    callback.__raw = helpers.mkLuaFun # lua
      ''
        require('lualine').refresh()
      '';
  }];

  extraPlugins = with pkgs.vimPlugins; [
    # theme
    catppuccin-nvim

    # extra
    unicode-vim
    lsp-progress-nvim
  ];

  userCommands.StatusLine.desc = "Toggle Status Line";
  userCommands.StatusLine.command.__raw = helpers.mkLuaFun
    # lua
    ''
      local toggle = function()
        if vim.g.unhide_lualine == nil then
          vim.g.unhide_lualine = true
        end  
        vim.g.unhide_lualine = not vim.g.unhide_lualine
        return vim.g.unhide_lualine
      end
      require('lualine').hide({ unhide = toggle() })
    '';

  plugins = lib.mkMerge [
    (import ./plugins/lualine.nix { inherit icons; })
    (import ./plugins/nvim-tree.nix { })
    (import ./plugins/which-key.nix { })
    (import ./plugins/web-devicons.nix { inherit icons; })
    (import ./plugins/treesitter.nix { inherit pkgs; })

    # (import ./plugins/image.nix { })
    # (import ./plugins/presence-nvim.nix { })
    # (import ./plugins/colorizer.nix { })
    # (import ./plugins/cursorline.nix { })
    # (import ./plugins/rainbow-delimiters.nix { })
    # (import ./plugins/indent-blankline.nix { })
    # (import ./plugins/smear-cursor.nix { })
    {
      # plugin yang belum dipisah, atau plugin kecil
      wakatime.enable = true;
      wakatime.autoLoad = false;

      cursorline.enable = true;

      rainbow-delimiters = {
        enable = true;
      };
    }
  ];
}
