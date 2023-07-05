{ config, pkgs, ... }:

{
  home.username = "arifinoid";
  home.homeDirectory = "/home/arifinoid";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    curl
    neofetch
    ripgrep
    htop
    trash-cli
    openvpn
    openvpn3
    alacritty
    nodejs_20
    go
    gcc9
    libstdcxx5
    python39
    git
    lazygit
    nerdfonts
    rustc
    cargo
    zig
    fishPlugins.bass
    speedtest-cli
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];


  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/arifinoid/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;
  programs.tmux = {
    enable = true;
    shortcut = "t";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      cpu
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      sensible
      yank
      better-mouse-mode
    ];
  };
  programs.fish = {
    enable = true;
    shellAbbrs = {
      rm = "trash";
      cat = "bat";
    };
    shellAliases = {
      cl = "clear";
    };
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";  
          repo = "z";
          rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
          sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
        };
      }
    ];
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      neovim-sensible
      nvim-surround
      nvim-treesitter
      dracula-nvim
      vim-fugitive
      vim-commentary
    ];
    # extraConfig = ''
      # syntax enable
      # colorscheme dracula
    # '';
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "Dracula";
    };
  };
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
