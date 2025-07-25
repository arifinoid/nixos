{
  plugins.which-key = {
    enable = true;
    settings = {
      plugins = {
        marks = true;
        registers = true;
        spelling = {
          enabled = true;
          suggestions = 20;
        };
      };
      icons = {
        breadcrumb = "»";
        separator = "➜";
        group = "+";
      };
      popup_mappings = {
        scroll_down = "<c-d>";
        scroll_up = "<c-u>";
      };
      window = {
        border = "rounded";
        position = "bottom";
        margin = [ 1 0 1 0 ];
        padding = [ 2 2 2 2 ];
        winblend = 0;
      };
      layout = {
        height = { min = 4 max = 25 };
        width = { min = 20 max = 50 };
        spacing = 3;
        align = "left";
      };
      ignore_missing = true;
      hidden = [ "<silent>" "<cmd>" "<Cmd>" "<CR>" "call" "lua" "^:" "^ " ];
      show_help = true;
      show_keys = true;
      triggers = "auto";
      triggers_blacklist = {
        i = [ "j" "k" ];
        v = [ "j" "k" ];
      };
      disable = {
        buftypes = [ ];
        filetypes = [ ];
      };
    };
  };
} 