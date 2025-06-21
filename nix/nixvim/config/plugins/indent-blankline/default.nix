{
  plugins.indent-blankline = {
    enable = true;
    settings = {
      char = "▏";
      context_char = "▏";
      show_trailing_blankline_indent = false;
      show_first_indent_level = true;
      use_treesitter = true;
      show_current_context = true;
      show_current_context_start = true;
      filetype_exclude = [
        "help"
        "git"
        "markdown"
        "snippets"
        "text"
        "gitcommit"
        "TelescopePrompt"
        "TelescopeResults"
        "DiffviewFiles"
        "Lazy"
        "mason"
        "notify"
        "noice"
        "lazy"
        "toggleterm"
        "lspinfo"
        "checkhealth"
        "help"
        "man"
        "gitmessengerpopup"
        "notify"
        "diff"
        "qf"
        "spectre_panel"
        "startuptime"
        "tsplayground"
        "PlenaryTestPopup"
        "neotest-summary"
        "neotest-output"
        "neotest-output-panel"
      ];
      buftype_exclude = [ "terminal" "nofile" ];
      context_patterns = [
        "class"
        "return"
        "function"
        "method"
        "^if"
        "^while"
        "jsx_element"
        "^for"
        "^object"
        "^table"
        "block"
        "arguments"
        "if_statement"
        "else_clause"
        "jsx_element"
        "jsx_self_closing_element"
        "try_statement"
        "catch_clause"
        "import_statement"
        "operation_type"
      ];
      space_char_blankline = " ";
      char_highlight_list = [ ];
      max_indent_increase = 1;
      show_end_of_line = false;
      show_indent_level = false;
    };
  };
} 