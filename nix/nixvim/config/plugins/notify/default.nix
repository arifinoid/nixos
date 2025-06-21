{
  plugins.notify = {
    enable = true;
    settings = {
      stages = "fade_in_slide_out";
      timeout = 3000;
      background_colour = "Normal";
      max_width = null;
      max_height = null;
      minimum_width = 50;
      icons = {
        ERROR = "  ";
        WARN = "  ";
        HINT = "  ";
        INFO = "  ";
        DEBUG = "  ";
        TRACE = "  ";
      };
      level = 2;
      top_down = true;
    };
  };
} 