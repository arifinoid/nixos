{
  config.autoCmd = [
    {
      event = "TextYankPost";
      pattern = "*";
      desc = "Highlight yanked text";
      callback = {
        __raw = ''
          function() vim.highlight.on_yank() end
        '';
      };
    }
  ];
}
