{ ... }:
{
  programs = {
    direnv = {
      enable = true;
      # shell yang dipakai user = fish + zsh (bash-only = hook ga pernah load)
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
