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
    # NOTE: dulu 5 aturan condition, semuanya user yang sama — collapse jadi satu.
    # Kalau nanti butuh split work/personal, tambah condition + user berbeda di sini.
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
