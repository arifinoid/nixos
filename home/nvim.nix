{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      neovim-sensible
      nvim-surround
      nvim-treesitter
      vim-fugitive
      vim-commentary
    ];
  };
}
