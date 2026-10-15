{ ... }:
{
  programs = {
    direnv = {
      enable = true;
      # Fish: JANGAN di-set — home-manager hardcode enable+readOnly
      # ("direnv otomatis ke-load di fish"). Nge-set manual = error eval.
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
