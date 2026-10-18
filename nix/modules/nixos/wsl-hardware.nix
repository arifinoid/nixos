{
  lib,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/lib/modules/6.6.87.2-microsoft-standard-WSL2" = {
    device = "none";
    fsType = "overlay";
  };

  fileSystems."/mnt/wsl" = {
    device = "none";
    fsType = "tmpfs";
  };

  fileSystems."/usr/lib/wsl/drivers" = {
    device = "drivers";
    fsType = "9p";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/562b76be-0380-4de1-82f0-1653810e153c";
    fsType = "ext4";
  };

  fileSystems."/mnt/c" = {
    device = "C:\134";
    fsType = "9p";
  };

  fileSystems."/mnt/wslg/run/user/1000" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/4d1021cc-12c2-4dfd-96b1-e1c216e89ae1"; }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
