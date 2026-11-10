{
  modulesPath,
  ezModules,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops.nixosModules.sops

    # Pin Bun to the version CI deploys with (job-hooker needs 1.4.x).
    ezModules.bun-overlay

    ezModules.vps-disko
    (modulesPath + "/profiles/qemu-guest.nix")

    ezModules.vps-networking
    ezModules.vps-backup
    ezModules.vps-adl
    ezModules.vps-web
    ezModules.vps-takar
    ezModules.vps-shell
    ezModules.vps-packages
    ezModules.vps-secrets
    ezModules.vps-ssh
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Swapfile on disk next to zram (vps-ssh.nix). zram is compressed RAM, so it
  # cannot absorb a deploy or an ingest spike on its own; this spills to
  # disk instead of letting systemd-oomd kill the app servers.
  swapDevices = [
    {
      device = "/swapfile";
      size = 2048;
    }
  ];

  # journald already holds 1.1 GB here and the default cap is 10% of /var.
  services.journald.extraConfig = "SystemMaxUse=500M";

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
