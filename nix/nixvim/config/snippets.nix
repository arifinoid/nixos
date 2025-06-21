{
  plugins.luasnip = {
    enable = true;
    settings = {
      history = true;
      update_events = "TextChanged,TextChangedI";
      delete_check_events = "TextChanged";
      ext_opts = {
        choiceNode = {
          active = {
            virt_text = [ [ "choiceNode" "Comment" ] ];
          };
        };
      };
      ext_base_prio = 300;
      ext_prio_increase = 1;
      enable_autosnippets = true;
      store_selection_keys = "<Tab>";
    };
  };

  extraConfigLua = ''
    -- Load snippets
    require("luasnip.loaders.from_lua").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Custom snippets
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    ls.add_snippets("go", {
      s("goprintf", {
        t("fmt.Printf("),
        i(1),
        t("%+v\\n, "),
        t({ "", ")" }),
      }),
    })

    -- Keymaps for snippet navigation
    vim.keymap.set({ "s", "i" }, "<c-l>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { desc = "Scroll through choice nodes" })

    vim.keymap.set("i", "<Tab>", function()
      return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<Tab>"
    end, { desc = "Expand or jump snippet", expr = true, silent = true })

    vim.keymap.set("s", "<Tab>", function()
      require("luasnip").jump(1)
    end, { desc = "Expand or jump snippet", expr = true, silent = true })

    vim.keymap.set("i", "<S-Tab>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, { desc = "Jump backwards snippet" })
  '';
} 