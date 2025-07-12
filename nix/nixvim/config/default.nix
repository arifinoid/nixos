{ pkgs, lib, ... }:
{
  imports = [
    ./autocmd.nix
    ./completion.nix
    ./globals.nix
    ./keys.nix
    ./lsp.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  config = {
    globals = { mapleader = " "; };

    plugins = {
      gitsigns.enable = true;
      oil.enable = true;
      undotree.enable = true;
      fugitive.enable = true;
      nvim-tree.enable = true;

      which-key.enable = true;
      toggleterm.enable = true;
      comment.enable = true;
      ts-autotag.enable = true;
      indent-blankline.enable = true;
      notify.enable = true;
      noice.enable = true;
      colorizer.enable = true;
      # Add git plugins
      git-conflict.enable = true;
      # Add web-devicons explicitly to fix warning
      web-devicons.enable = true;

      # Add obsidian
      obsidian = {
        enable = true;
        settings = {
          workspaces = [
            {
              name = "work";
              path = "~/vaults/work";
            }
            {
              name = "home";
              path = "~/vaults/home";
            }
          ];
        };
      };
      # Add wakatime
      wakatime.enable = true;
      # Add hop
      hop.enable = true;
      # Add todo-comments
      todo-comments.enable = true;
      # Add fidget
      fidget.enable = true;
      # Add mini
      mini.enable = true;
      # Add llm
      llm.enable = true;
      # Add missing plugins that are referenced in configs
      lsp-signature.enable = true;
      trouble.enable = true;
      # Add debugging support
      dap.enable = true;
      # Add autopairs for better editing experience
      nvim-autopairs.enable = true;
    };

    extraPackages = with pkgs; [
      # Formatters
      asmfmt
      astyle
      black
      cmake-format
      gofumpt
      golines
      gotools
      isort
      nixfmt-rfc-style
      nodePackages.prettier
      prettierd
      rustfmt
      shfmt
      stylua
      # Linters
      eslint_d
      gitlint
      golangci-lint
      hadolint
      html-tidy
      luajitPackages.luacheck
      markdownlint-cli
      nodePackages.jsonlint
      pylint
      ruff
      shellcheck
      vale
      yamllint
      # Debuggers / misc deps
      asm-lsp
      bashdb
      clang-tools
      delve
      fd
      (if stdenv.isDarwin then null else gdb) # Not supported on MacOS
      go
      lldb_17
      llvmPackages_17.bintools-unwrapped
      marksman
      python3
      ripgrep
      (if stdenv.isDarwin then null else rr) # Not supported on MacOS
      tmux-sessionizer
      typescript
      zig
      # Additional packages for new plugins
      cmake
      nodePackages.typescript
      nodePackages.typescript-language-server
      # For wakatime
      wakatime
      # For git plugins
      git
    ];

  };

}
