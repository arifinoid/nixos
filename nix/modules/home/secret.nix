{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    sops
    gnupg
    pinentry
  ];

  programs.gpg = {
    enable = true;
    settings = {
      use-agent = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
  };

  # Environment variables for API keys
  # Note: SOPS secrets are handled at the system level
  # Use pass for home-manager environment variables
  home.sessionVariables = {
    # OPENAI_API_KEY will be available from the system-level SOPS configuration
  };
  
}