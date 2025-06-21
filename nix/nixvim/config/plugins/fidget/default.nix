{
  plugins.fidget = {
    enable = true;
    settings = {
      window = {
        relative = "win";
        blend = 0;
        zindex = 45;
        border = "none";
      };
      fmt = {
        stack_upwards = true;
        max_width = 0;
        fidget = {
          function = "fidget.progress";
          function_args = {
            done_icon = " ";
            done_style = "Constant";
            spinner_padding = 0;
            format = " {spinner} {text}";
          };
        };
        task = {
          function = "fidget.progress";
          function_args = {
            done_icon = " ";
            done_style = "Constant";
            spinner_padding = 0;
            format = " {spinner} {text}";
          };
        };
        notification = {
          function = "fidget.notification";
          function_args = {
            format = " {icon} {text}";
            reverse = false;
            merge = true;
            dedupe = true;
            hide_from_history = false;
            icon_separator = " ";
            group_by = "notification.key";
            overrides = {
              notification = {
                reverse = true;
              };
            };
          };
        };
        default_handler = {
          function = "fidget.notification";
          function_args = {
            format = " {icon} {text}";
            reverse = false;
            merge = true;
            dedupe = true;
            hide_from_history = false;
            icon_separator = " ";
            group_by = "notification.key";
            overrides = {
              notification = {
                reverse = true;
              };
            };
          };
        };
      };
      sources = {
        ["null-ls"] = {
          ignore = false;
        };
        ["nvim.cmp"] = {
          ignore = false;
        };
        ["nvim.dap"] = {
          ignore = false;
        };
        ["nvim.lsp"] = {
          ignore = false;
        };
        ["nvim.treesitter"] = {
          ignore = false;
        };
      };
      debug = {
        logging = {
          level = "warn";
          sink = "fidget.logger";
        };
      };
    };
  };
} 