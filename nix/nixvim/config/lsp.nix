{ pkgs, ... }:
{
  plugins = {
    lsp = {
      enable = true;
      servers = {
        asm_lsp.enable = true;

        bashls.enable = true;

        biome.enable = true;
        biome.autostart = true;

        clangd.enable = true;
        cmake.enable = true;

        cssls.enable = true;

        dockerls.enable = true;

        gopls.enable = true;

        html.enable = true;

        jsonls.enable = true;

        lua_ls.enable = true;

        marksman.enable = true;

        nixd.enable = true;
        nixd.autostart = true;

        pyright.enable = true;

        ruff.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };

        ts_ls.enable = true;

        terraformls.enable = true;

        yamlls.enable = true;

        zls.enable = true;
      };
    };

    lsp-format.enable = true;

    lspkind.enable = true;
    lspkind.cmp.enable = true;

    lspsaga.enable = true;
    lspsaga.lightbulb.sign = false;
    lspsaga.lightbulb.virtualText = true;
    lspsaga.lightbulb.debounce = 40;

    luasnip.enable = true;
    luasnip.lazyLoad.settings.event = "InsertEnter";

    trouble.enable = true;
    trouble.lazyLoad.settings.cmd = "Trouble";

    wtf.enable = true;

    nvim-autopairs.enable = true;
    nvim-autopairs.lazyLoad.settings.event = "InsertEnter";

    cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "nvim_lsp_signature_help"; }
        { name = "nvim_lsp_document_symbol"; }
        { name = "luasnip"; }
        { name = "calc"; }
        { name = "yanky"; }
        {
          name = "npm";
          keyword_length = 4;
        }
        {
          name = "emoji";
          trigger_characters = [ ":" ];
        }
        { name = "async_path"; }
      ];
      settings.mapping."<C-space>" = "cmp.mapping.complete()";
      settings.mapping."<C-x>" = "cmp.mapping.close()";
      settings.mapping."<C-d>" = "cmp.mapping.scroll_docs(4)";
      settings.mapping."<C-u>" = "cmp.mapping.scroll_docs(-4)";
      settings.mapping."<CR>" = "cmp.mapping.confirm({ select = true })";
      settings.mapping."<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
      settings.mapping."<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
    };
  };
  extraPlugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    typescript-tools-nvim
  ];
}
