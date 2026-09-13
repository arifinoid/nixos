{
  lib,
  osConfig,
  pkgs,
  inputs,
  ...
}:
let
  isWSLHost = (osConfig.networking.hostName or "") == "wsl-arifinoid";
in
{
  xdg.configFile."wezterm/wezterm.lua" = lib.mkIf (!isWSLHost) {
    source = "${inputs.self}/.config/wezterm/wezterm.lua";
  };

  home.activation.weztermWindowsConfig = lib.mkIf isWSLHost (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      windows_user_home=""
      for candidate in /mnt/c/Users/*; do
        case "$candidate" in
          "/mnt/c/Users/All Users"|"/mnt/c/Users/Default"|"/mnt/c/Users/Default User"|"/mnt/c/Users/Public")
            continue
            ;;
        esac
        if [ -r "$candidate/AppData/Local" ]; then
          windows_user_home="$candidate"
          break
        fi
      done
      if [ -z "$windows_user_home" ]; then
        echo "Could not find readable Windows user profile in /mnt/c/Users" >&2
        exit 1
      fi
      $DRY_RUN_CMD install -Dm644 "${inputs.self}/.config/wezterm/wezterm.lua" "$windows_user_home/.wezterm.lua"
    ''
  );

  home.packages = [ pkgs.wezterm ];
}
