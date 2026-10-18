{ inputs, ... }:

{
  imports = [ inputs.disko.nixosModules.disko ];

  # Sumopod/Hermes (Tencent Cloud), disk virtio 40G.
  # GPT: ESP 512M (vfat) + BIOS boot 2M + ext4 root.
  # ESP dibutuhkan untuk removable-EFI; EF02 untuk legacy BIOS boot.
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
