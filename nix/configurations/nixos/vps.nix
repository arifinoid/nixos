{
  modulesPath,
  ezModules,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops.nixosModules.sops
    ezModules.vps-disko
    (modulesPath + "/profiles/qemu-guest.nix")

    ezModules.vps-networking
    ezModules.vps-web
    ezModules.vps-shell
    ezModules.vps-packages
    ezModules.vps-secrets
    ezModules.vps-ssh
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Swapfile on disk next to zram (vps-ssh.nix). zram is compressed RAM, so it
  # cannot absorb a docker build or an ingest spike on its own; this spills to
  # disk instead of letting systemd-oomd kill a container.
  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  # journald already holds 1.1 GB here and the default cap is 10% of /var.
  services.journald.extraConfig = "SystemMaxUse=500M";

  # Docker's default json-file driver has no size limit, so a long-lived deploy
  # would slowly eat the disk. Cap it at 30 MB per container.
  virtualisation.docker.daemon.settings = {
    log-driver = "json-file";
    log-opts = {
      max-size = "10m";
      max-file = "3";
    };
  };

  boot.loader.grub = {
    device = "/dev/vda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [ "net.ifnames=0" ];

  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  environment.variables.SSL_CERT_DIR = "/etc/ssl/certs";
}
