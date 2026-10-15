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
    # NOTE: alias git JANGAN diawali "git " — `git gb` me-expand jadi `git <value>`,
    # jadi value "git branch" akan jadi `git git branch` (broken).
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
        condition = "gitdir:~/Documents/personal/";
        contents.user = personal;
      }
      {
        condition = "gitdir:~/.config/";
        contents.user = personal;
      }
      {
        condition = "gitdir:~/telekasten-notes/";
        contents.user = personal;
      }
      {
        condition = "gitdir:~/";
        contents.user = personal;
      }
      {
        condition = "gitdir:~/Documents/obsidian";
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
