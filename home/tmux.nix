{ pkgs, ... }:
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
    extraConfig = "";
  };
}
