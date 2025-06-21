{
  plugins.comment = {
    enable = true;
    settings = {
      padding = true;
      sticky = true;
      ignore = "^$";
      toggler = {
        line = "gcc";
        block = "gbc";
      };
      opleader = {
        line = "gc";
        block = "gb";
      };
      extra = {
        above = "gcO";
        below = "gco";
        eol = "gcA";
      };
      mappings = {
        basic = true;
        extra = true;
        extended = false;
      };
      pre_hook = null;
      post_hook = null;
    };
  };
} 