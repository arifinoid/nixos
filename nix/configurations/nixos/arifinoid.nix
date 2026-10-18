{
  ezModules,
  pkgs,
  inputs,
  ...
}:

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

  # SSH: selain akses remote, enable=true bikin sops-nix baru happy
  # (opsi openssh.generateHostKeys sudah dihapus upstream; short-circuit
  # hanya saat enable=true).
  services.openssh.enable = true;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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
    (discord.override {
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
