{ icons, ... }:
{
  plugins.dashboard = {
    enable = true;
    settings = {
      theme = "hyper";
      hide.statusline = true;
      hide.tabline = true;
      config = {
        week_header.enable = false;
        project.enable = true;
        mru.limit = 20;
        shortcut = [
          {
            key = "<S> f f";
            icon = "${icons.file} ";
            desc = "Find File ";
            action = "Telescope find_files";
          }
          {
            key = "<S> f o";
            icon = "${icons.recent} ";
            desc = "Recents ";
            action = "Telescope oldfiles";
          }
          {
            key = "<S> f w";
            icon = "${icons.word} ";
            desc = "Find Word ";
            action = "Telescope live_grep";
          }
          {
            key = "<S> f n";
            icon = "${icons.plus1} ";
            desc = "New File ";
            action = "new";
          }
          {
            key = "<S> b m";
            icon = "${icons.bookmark} ";
            desc = "Bookmarks ";
            action = "Telescope marks";
          }
        ];
        header = [
          	"[[              _ _____             _     __]]"
            "[[  ____ ______(_) __(_)___  ____  (_)___/ /]]"
            "[[ / __ `/ ___/ / /_/ / __ \/ __ \/ / __  / ]]"
            "[[/ /_/ / /  / / __/ / / / / /_/ / / /_/ /  ]]"
            "[[\__,_/_/  /_/_/ /_/_/ /_/\____/_/\__,_/   ]]"
          ];
        };
      };
    };
}