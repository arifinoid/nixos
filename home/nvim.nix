{ pkgs, ... }:
let
  toLua = str: "lua << EOF\n${str}\nEOF\n";
  toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      # package manager
      lazy-nvim

      # LSP
      {
        plugin = lspkind-nvim;
        config = toLuaFile ../nvim/plugins/lspkind.lua;
      }
      { plugin = null-ls-nvim; config = toLuaFile ../nvim/plugins/null-ls.lua; }
      { plugin = mason-nvim; config = toLuaFile ../nvim/plugins/mason.lua; }
      { plugin = vim-prettier; config = toLuaFile ../nvim/plugins/prettier.lua; }
      nvim-lspconfig
      mason-null-ls
      mason-lspconfig-nvim
      # autocompletion
      {
        plugin = nvim-cmp;
        config = toLuaFile ../nvim/plugins/cmp.lua;
      }
      codeium
      friendly-snippets
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help
      cmp-buffer
      cmp-cmdline
      cmp-path
      luasnip
      cmp_luasnip
      cmp-nvim-lua
      {
        plugin = lualine-nvim;
        config = toLuaFile ../nvim/plugins/lualine.lua;
      }
      { plugin = indent-blankline-nvim; config = toLuaFile ../nvim/plugins/indentline.lua; }
      lualine-lsp-progress
      # snippets
      {
        plugin = cmp_luasnip;
        config = toLuaFile ../nvim/plugins/cmp_luasnip.lua;
      }
      luasnip
      friendly-snippets

      # telescope
      {
        plugin = telescope-nvim;
        config = toLuaFile ../nvim/plugins/telescope.lua;
      }
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim


      # treesitter
      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-bash
          p.tree-sitter-fish
          p.tree-sitter-regex
          p.tree-sitter-query
          p.tree-sitter-lua
          p.tree-sitter-python
          p.tree-sitter-prisma
          p.tree-sitter-dockerfile
          p.tree-sitter-json
          p.tree-sitter-javascript
          p.tree-sitter-typescript
          p.tree-sitter-graphql
          p.tree-sitter-comment
          p.tree-sitter-markdown
          p.tree-sitter-http
          p.tree-sitter-html
          p.tree-sitter-tsx
        ]));
        config = toLuaFile ../nvim/plugins/treesitter.lua;
      }
      nvim-ts-rainbow

      vim-nix

      # debugging
      neodev-nvim
      { plugin = nvim-dap; config = toLuaFile ../nvim/plugins/dap.lua; }
      nvim-dap-ui

      # git
      { plugin = git; config = toLuaFile ../nvim/plugins/git.lua; }
      { plugin = gitsigns-nvim; config = toLuaFile ../nvim/plugins/gitsigns.lua; }
      { plugin = git-conflict-nvim; }
      { plugin = vimagit; }

      # session
      { plugin = vim-prosession; }
      vim-obsession
      mini-nvim

      # misc
      { plugin = nvim-web-devicons; config = toLuaFile ../nvim/plugins/nvim-web-devicons.lua; }
      { plugin = nvim-tree-lua; config = toLuaFile ../nvim/plugins/nvim-tree.lua; }
      barbar-nvim
      { plugin = nvim-autopairs; config = toLuaFile ../nvim/plugins/autopairs.lua; }
      { plugin = fidget-nvim; }
      { plugin = comment-nvim; }
      { plugin = nvim-comment; config = toLuaFile ../nvim/plugins/nvim-comment.lua; }
      todo-comments-nvim
      nvim-ts-context-commentstring
      nvim-surround
      { plugin = catppuccin-nvim; config = toLuaFile ../nvim/plugins/catppuccin.lua; }
      { plugin = markdown-preview-nvim; }
      {
        plugin = noice-nvim;
        config = toLuaFile ../nvim/plugins/noice.lua;
      }
      nui-nvim
      nvim-notify

      { plugin = alpha-nvim; config = toLuaFile ../nvim/plugins/alpha.lua; }
      { plugin = which-key-nvim; config = toLuaFile ../nvim/plugins/which-key.lua; }
      { plugin = nvim-notify; config = toLuaFile ../nvim/plugins/nvim-notify.lua; }
      { plugin = toggleterm-nvim; config = toLuaFile ../nvim/plugins/toggleterm.lua; }
      undotree
      { plugin = project-nvim; config = toLuaFile ../nvim/plugins/project.lua; }

      { plugin = impatient-nvim; config = toLua "require(\"impatient\").enable_profile()"; }
    ];
    extraPackages = with pkgs; [
      luajitPackages.lua-lsp
      rnix-lsp

      xclip
      wl-clipboard
    ];


    extraLuaConfig = ''
      ${builtins.readFile ../nvim/options.lua}
      ${builtins.readFile ../nvim/keymaps.lua}
      ${builtins.readFile ../nvim/autocommands.lua}
    '';
  };
}
