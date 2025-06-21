{
  plugins.obsidian = {
    enable = true;
    settings = {
      dir = "~/obsidian-vault";
      completion = {
        nvim_cmp = true;
        min_chars = 2;
        new_notes_location = "current_dir";
        prepend_note_id = true;
        prepend_note_path = false;
        use_path_only = false;
        tags = {
          subdirs = true;
          min_chars = 2;
        };
      };
      daily_notes = {
        folder = "notes/dailies";
        date_format = "%Y-%m-%d";
        alias_format = "%B %-d, %Y";
        template = null;
      };
      workspaces = [
        {
          name = "work";
          path = "~/vaults/work";
        }
        {
          name = "home";
          path = "~/vaults/home";
        }
      ];
      follow_url_func = "vim.ui.open";
      note_id_func = "auto";
      note_path_func = "relative";
      disable_frontmatter = false;
      use_advanced_uri = true;
      open_app_foreground = false;
      finder = "telescope.nvim";
      sort_by = "modified";
      sort_reversed = true;
      open_notes_in = "current";
      ui = {
        enable = true;
        update_debounce = 200;
        checkboxes = {
          " " = [ "space" "unchecked" ];
          "x" = [ "x" "checked" ];
          ">" = [ ">" "transferred" ];
          "~" = [ "~" "cancelled" ];
        };
        external_link_icon = " ";
        reference_text = " ";
        highlight_text = " ";
        tags = {
          cwd = "~/obsidian-vault";
        };
        use_dropdown = true;
        code_blocks = {
          copy_btn = true;
          delete_btn = true;
        };
      };
      attachments = {
        img_folder = "assets/imgs";
        img_text_func = "filename";
        img_link_func = "absolute";
      };
      callbacks = { };
      log_level = 1;
      picker = {
        name = "telescope.nvim";
        mappings = {
          new = "<C-x>";
          insert_link = "<C-l>";
          insert_img = "<C-k>";
          insert_my_img = "<C-m>";
          preview = "<C-p>";
          open_in_browser = "<C-b>";
          copy_url = "<C-y>";
          toggle_checkbox = "<C-space>";
          insert_smart_list = "<C-O>";
        };
      };
      new_notes_location = "current_dir";
      preferred_link_style = "markdown";
      templates = {
        subdir = "templates";
        date_format = "%Y-%m-%d-%a";
        time_format = "%H:%M";
        tags = "";
      };
    };
  };
} 