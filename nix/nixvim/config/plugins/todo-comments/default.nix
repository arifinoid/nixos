{
  plugins.todo-comments = {
    enable = true;
    settings = {
      signs = true;
      sign_priority = 8;
      keywords = {
        FIX = {
          icon = " ";
          color = "error";
          alt = [ "FIXME" "BUG" "FIXIT" "ISSUE" ];
        };
        TODO = {
          icon = " ";
          color = "info";
        };
        HACK = {
          icon = " ";
          color = "warning";
        };
        WARN = {
          icon = " ";
          color = "warning";
          alt = [ "WARNING" "XXX" ];
        };
        PERF = {
          icon = " ";
          alt = [ "OPTIM" "PERFORMANCE" "OPTIMIZE" ];
        };
        NOTE = {
          icon = " ";
          color = "hint";
          alt = [ "INFO" ];
        };
        TEST = {
          icon = "⏲ ";
          color = "test";
          alt = [ "TESTING" "PASSED" "FAILED" ];
        };
      };
      gui_style = {
        fg = "NONE";
        bg = "BOLD";
      };
      merge_keywords = true;
      highlight = {
        before = "";
        keyword = "wide";
        after = "fg";
        pattern = ".*<(KEYWORDS)\\s*:";
        comments_only = true;
        max_line_len = 400;
        exclude = [ ];
      };
      search = {
        command = "rg";
        args = [
          "--color=never"
          "--no-heading"
          "--with-filename"
          "--line-number"
          "--column"
        ];
        pattern = "\\b(KEYWORDS):";
      };
    };
  };
} 