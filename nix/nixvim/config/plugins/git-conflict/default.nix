{
  plugins.git-conflict = {
    enable = true;
    settings = {
      default_mappings = true;
      disable_diagnostics = false;
      highlights = {
        incoming = "DiffAdd";
        current = "DiffText";
      };
    };
  };
} 