{}: {
  nvim-tree = {
    enable = true;
    disableNetrw = true;
    view.side = "left";
    view.width = 25;
    respectBufCwd = true;
    autoReloadOnWrite = true;
    git.enable = true;
    filters.dotfiles = true;
    renderer.highlightGit = true;
    renderer.indentMarkers.enable = true;
  };
}
