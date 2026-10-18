# Sumopod/Hermes (Tencent Cloud), disk virtio 40G.
# ESP buat removable-EFI + EF02 buat legacy BIOS boot (hybrid).

{ inputs, ... }:

{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.main = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          bios = {
            size = "2M";
            type = "EF02";
            priority = 1;
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
