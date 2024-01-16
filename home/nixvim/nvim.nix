{
  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";
    globals.maplocalleader = " ";

    extraConfigLuaPre = ''
      vim.g.mapleader = " "
    '';

    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      foldcolumn = "0";
    };

    clipboard.providers.wl-copy.enable = true;
  };
}
