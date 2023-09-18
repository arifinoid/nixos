{ pkgs, libs, ... }:
{
  home.shellAliases = {
    tms = "tmux source-file ~/.config/.tmux.conf";
    tmk = "tmux kill-session -a";
    ide = "tmux split-window -v -p 30;tmux split-window -h -p 66;tmux split-window -h -p 50";
  };
  programs.tmux = {
    enable = true;
    shortcut = "t";
    mouse = true;
    newSession = true;
    reverseSplit = true;
    customPaneNavigationAndResize = true;
    prefix = "C-t";
    terminal = "screen-256color";
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
      catppuccin
    ];
    extraConfig = ''
      #### Key bindings
      unbind %
      bind-key | split-window -h
      unbind '"'
      bind-key - split-window -v

      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Reload settings
      bind -r e kill-pane -a

      # vim-like pane switching
      bind -r k select-pane -U 
      bind -r j select-pane -D 
      bind -r h select-pane -L 
      bind -r l select-pane -R 

      # Moving window
      bind-key -n C-S-Left swap-window -t -1 \; previous-window
      bind-key -n C-S-Right swap-window -t +1 \; next-window

      # Resizing pane
      bind -r C-k resize-pane -U 5
      bind -r C-j resize-pane -D 5
      bind -r C-h resize-pane -L 5
      bind -r C-l resize-pane -R 5

      #### basic settings
      set-option -g status-justify "left"

      # look'n feel
      set-option -g status-fg cyan
      set-option -g status-bg black
      set -g pane-active-border-style fg=colour166,bg=default
      set -g window-style fg=colour10,bg=default
      set -g window-active-style fg=colour12,bg=default
      set-option -g history-limit 64096
      set -sg escape-time 10

      #### COLOUR
      # default statusbar colors
      set-option -g status-style bg=colour235,fg=colour136,default

      # default window title colors
      set-window-option -g window-status-style fg=colour244,bg=colour234,dim

      # active window title colors
      set-window-option -g window-status-current-style fg=colour166,bg=default,bright

      # pane border
      set-option -g pane-border-style fg=colour23 #base02
      set-option -g pane-active-border-style fg=green,bg=default

      # message text
      set-option -g message-style bg=colour235,fg=colour166

      # pane number display
      set-option -g display-panes-active-colour colour33 #blue
      set-option -g display-panes-colour colour166 #orange

      # clock
      set-window-option -g clock-mode-colour colour64 #green

      # allow the title bar to adapt to whatever host you connect to
      set -g set-titles on
      set -g set-titles-string "#T"
    '';
  };

  home.packages = with pkgs; lib.optionals stdenv.isDarwin [
    reattach-to-user-namespace
  ];
}
