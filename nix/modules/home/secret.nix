{ pkgs, ... }:
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
}
