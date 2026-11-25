{
  ezModules,
  pkgs,
  inputs,
  ...
}:

let
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    ezModules.arifinoid-hardware
    ezModules.bun-overlay
    ezModules.common
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "arifinoid";

  networking.networkmanager.enable = true;

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "524288";
    }
  ];

  services.openssh.enable = true;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  # COSMIC desktop environment (try-out). Plasma 6 + SDDM kept commented so the
  # switch back is a one-line change; only one display manager can own the VT.
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;

  # The pinned stable nixpkgs only ships COSMIC 1.0.0-alpha.7; the overlay swaps
  # in the 1.11.0 package set from nixpkgs-unstable while the rest of the system
  # stays on stable. Host-local, so the VPS and WSL hosts are unaffected.
  nixpkgs.overlays = [
    (_final: _prev: {
      cosmic-comp = unstablePkgs.cosmic-comp;
      cosmic-session = unstablePkgs.cosmic-session;
      cosmic-settings = unstablePkgs.cosmic-settings;
      cosmic-settings-daemon = unstablePkgs.cosmic-settings-daemon;
      cosmic-applets = unstablePkgs.cosmic-applets;
      cosmic-app-library = unstablePkgs.cosmic-app-library;
      cosmic-applibrary = unstablePkgs.cosmic-app-library;
      cosmic-bg = unstablePkgs.cosmic-bg;
      cosmic-edit = unstablePkgs.cosmic-edit;
      cosmic-files = unstablePkgs.cosmic-files;
      cosmic-greeter = unstablePkgs.cosmic-greeter;
      cosmic-icons = unstablePkgs.cosmic-icons;
      cosmic-idle = unstablePkgs.cosmic-idle;
      cosmic-launcher = unstablePkgs.cosmic-launcher;
      cosmic-notifications = unstablePkgs.cosmic-notifications;
      cosmic-osd = unstablePkgs.cosmic-osd;
      cosmic-panel = unstablePkgs.cosmic-panel;
      cosmic-player = unstablePkgs.cosmic-player;
      cosmic-randr = unstablePkgs.cosmic-randr;
      cosmic-screenshot = unstablePkgs.cosmic-screenshot;
      cosmic-term = unstablePkgs.cosmic-term;
      cosmic-wallpapers = unstablePkgs.cosmic-wallpapers;
      cosmic-workspaces-epoch = unstablePkgs.cosmic-workspaces-epoch;
      xdg-desktop-portal-cosmic = unstablePkgs.xdg-desktop-portal-cosmic;
    })
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.arifinoid.extraGroups = [
    "networkmanager"
    "wheel"
    "docker"
  ];
  users.users.arifinoid.packages = with pkgs; [
    kdePackages.kate
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    kdePackages.partitionmanager
    code-cursor
    vscode
    nixd
    nix-search
    cachix
    fzf
    zoom-us
    (unstablePkgs.discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    inputs.self.packages.${pkgs.system}.nvim
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
  environment.variables = {
    MESA_SHADER_CACHE_DIR = "$HOME/.cache/mesa_shader_cache";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: [
        pkgs.vulkan-tools
        pkgs.mesa
      ];
    };
  };

  services.blueman.enable = true;

  xdg.portal.enable = true;
  xdg.icons.enable = true;
  xdg.menus.enable = true;
  xdg.sounds.enable = true;

}
