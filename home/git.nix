{ pkgs, ...}:
 let
     work = {
        name = "rohmadarifin";
        email = "rohmad.arifin@efishery.com";
     };
     personal = {
        name = "arifinoid";
        email = "rohmadarifin007@gmail.com";
     };
 in
{
    programs.git = {
        enable = true;
        delta = {
            enable = true;
        };
        aliases = {
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
        includes = [
            {
                condition = "gitdir:~/Documents/work/";
                contents.user = work;
            }
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
