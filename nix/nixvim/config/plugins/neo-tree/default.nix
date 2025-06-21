{
  plugins.neo-tree = {
    enable = true;

    buffers.followCurrentFile.enabled = true;
    autoCleanAfterSessionRestore = true;
    closeIfLastWindow = true;

    sourceSelector = {
      winbar = true;
      sources = [
        {
          source = "filesystem";
          displayName = " File";
        }
        {
          source = "buffers";
          displayName = "󰈙 Bufs";
        }
        {
          source = "git_status";
          displayName = "󰊢 Git";
        }
        {
          source = "diagnostics";
          displayName = "󰒡 Diagnostic";
        }
      ];
    };

    filesystem = {
      followCurrentFile.enabled = true;
      hijackNetrwBehavior = "open_current";
      useLibuvFileWatcher = true;
    };

    enableDiagnostics = true;
    enableGitStatus = true;
    enableModifiedMarkers = true;
    enableRefreshOnWrite = true;

    window = {
      width = 30;
      mappings = {
        "<space>" = { };
      };
    };
  };
}
