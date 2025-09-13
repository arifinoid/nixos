{ osConfig, lib, ... }:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  programs.firefox.enable = !isWSLHost;
  programs.chromium.enable = !isWSLHost;
}