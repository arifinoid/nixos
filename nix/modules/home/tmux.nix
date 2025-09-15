{ pkgs, libs, ... }: {
  home.shellAliases = {
    tms = "tmux source-file ~/.config/.tmux.conf";
    tmk = "tmux kill-session -a";
    ide =
      "tmux split-window -v -p 30;tmux split-window -h -p 66;tmux split-window -h -p 50";
  };
  programs.tmux = {
    enable = true;
    shortcut = "t";
    mouse = true;
    newSession = true;
    reverseSplit = true;
    customPaneNavigationAndResize = true;
    prefix = "C-t";
    terminal = "tmux-256color";
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      cpu
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      sensible
      yank
      better-mouse-mode
      {
        plugin = catppuccin;
        extraConfig = builtins.readFile ./plugins.catppuccin.conf;
      }
    ];
    extraConfig = (builtins.readFile ./tmux.conf) + ''
      set -g default-terminal "tmux-256color"
      set -as terminal-overrides ",*:RGB"
    '';
  };

  home.packages = with pkgs;
    [ ncurses ]
    ++ lib.optionals stdenv.isDarwin [ reattach-to-user-namespace ];
}
