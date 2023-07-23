{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      rm = "trash";
      cat = "bat";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      

      # git
      gpo = "git pull origin";
      ggpo = "git push origin";
      gcm = "git checkout master";
      gc = "git checkout";
      gr = "git restore";
      gst = "git status";
      gsta = "git stash";
      gstl = "git stash list";
      gstp = "git stash pop";
      gf = "git fetch";
      gb = "git branch";
      gm = "git merge";
      gpom = "git pull origin master";
      grv = "git remote -v";
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
