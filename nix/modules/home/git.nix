{ pkgs, ... }:
let
  personal = {
    name = "arifinoid";
    email = "rohmadarifin007@gmail.com";
  };
in
{
  home.packages = with pkgs; [ git-filter-repo ];

  programs.git = {
    enable = true;
    delta = {
      enable = true;
    };
    aliases = {
      gpo = "pull origin";
      ggpo = "push origin";
      gcm = "checkout main";
      gc = "checkout";
      gr = "restore";
      gst = "status";
      gsta = "stash";
      gstl = "stash list";
      gstp = "stash pop";
      gf = "fetch";
      gb = "branch";
      gm = "merge";
      gpom = "pull origin main";
      grv = "remote -v";
    };
    includes = [
      {
        condition = "gitdir:~/";
        contents.user = personal;
      }
    ];
  };

  programs.gh = {
    settings.git.protocol = "ssh";
    enable = true;
  };

  programs.lazygit = {
    enable = true;
  };
}
