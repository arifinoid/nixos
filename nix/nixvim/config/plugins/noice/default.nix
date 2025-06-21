{
  plugins.noice = {
    enable = true;
    settings = {
      cmdline = {
        enabled = true;
        view = "cmdline_popup";
        opts = {
          position = {
            row = "50%";
            col = "50%";
          };
          size = {
            width = 60;
            height = "auto";
          };
        };
        icons = {
          ["/"] = { icon = " " desc = "search" };
          ["?"] = { icon = " " desc = "search backwards" };
          [":"] = { icon = " " desc = "command" };
          ["!"] = { icon = " " desc = "shell" };
        };
      };
      messages = {
        enabled = true;
        view = "notify";
        view_error = "notify";
        view_warn = "notify";
        view_history = "messages";
        view_search = "virtualtext";
      };
      popupmenu = {
        enabled = true;
        backend = "nui";
      };
      redirect = {
        view = "popup";
        filter = { event = "msg_show" };
      };
      notify = {
        enabled = true;
        view = "notify";
      };
      lsp = {
        progress = {
          enabled = true;
          format = "lsp_progress";
          format_done = "lsp_progress_done";
          throttle = 1000 / 30;
          view = "mini";
        };
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true;
          ["vim.lsp.util.stylize_markdown"] = true;
          ["cmp.entry.get_documentation"] = true;
        };
      };
      markdown = {
        hover = {
          ["|(%S-)|"] = "vim.cmd.help";
          ["%[.-%]%((%S-)%)"] = "require('noice.util').open";
        };
        highlights = {
          ["|%S-|"] = "@text.reference";
          ["@%S+"] = "@parameter";
          ["^%s*(Parameters:)"] = "@text.strong";
          ["^%s*(Return:)"] = "@text.strong";
          ["^%s*(See also:)"] = "@text.strong";
          ["{%S-}"] = "@parameter";
        };
      };
      health = {
        checker = true;
      };
      smart_move = {
        enabled = true;
        excluded_filetypes = [ "cmp_menu" "cmp_docs" "notify" ];
      };
      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
        inc_rename = false;
        lsp_doc_border = false;
      };
      throttle = 1000 / 30;
      views = { };
      routes = { };
    };
  };
} 