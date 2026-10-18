# VPS Sumopod/Hermes (Tencent Cloud, 43.173.26.172), KVM/BISO firmware.
# Deploy: nixos-rebuild switch --flake .#vps --target-host root@43.173.26.172
#
# NOTE: ini server single-user tanpa home-manager. Sengaja TIDAK pakai
# ezModules.common (sops/age key-nya belum disiapin buat VPS); beban
# tools deklaratif ditangani sendiri di sini.

{
  modulesPath,
  pkgs,
  ezModules,
  ...
}:

{
  imports = [
    ezModules.vps-disko
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # Hybrid boot: grub MBR (BIOS) DAN removable EFI ke /boot, jadi apapun
  # mode firmware (BIOS legacy atau UEFI), boot path tersedia.
  # (Kasus serius dulu: firmware-nya ternyata BIOS, grub EFI-only gak
  # pernah kebaca -> VPS unreachable sesudah install.)
  boot.loader.grub = {
    device = "/dev/vda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [ "net.ifnames=0" ];

  # Tencent gak menyediakan DHCP yang stabil untuk non-cloud-init; pakai
  # static via systemd-networkd. Data diambil dari Ubuntu sebelum install:
  #   eth0 = 10.11.26.201/22, gw 10.11.24.1 (gateway di subnet yang sama)
  #   dns  = 183.60.82.98 (internal Tencent, fallback 8.8.8.8)
  # IP publik 43.173.26.172 = DMAT ke internal ini.
  networking = {
    hostName = "vps";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    useNetworkd = true;
    defaultGateway = {
      address = "10.11.24.1";
      interface = "eth0";
    };
    nameservers = [ "183.60.82.98" "8.8.8.8" ];
    interfaces.eth0 = {
      ipv4.addresses = [ { address = "10.11.26.201"; prefixLength = 22; } ];
    };
    firewall.allowedTCPPorts = [ 22 ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # CA bundle global — dipakai juga python/uv hermes-agent buat HTTPS
  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  environment.variables.SSL_CERT_DIR = "/etc/ssl/certs";

  # Tools CLI
  environment.systemPackages = with pkgs; [
    git
    fastfetch
    btop
    neovim
    python3
    # hermes-agent + rtk terpasang imperatif (installer resmi masing-masing)
    # di /root/.local/bin; wrapper bikin command tersedia di semua session.
    (pkgs.writeShellScriptBin "hermes" ''
      exec /root/.local/bin/hermes "$@"
    '')
    (pkgs.writeShellScriptBin "rtk" ''
      exec /root/.local/bin/rtk "$@"
    '')
  ];

  # Zsh + oh-my-zsh sebagai default shell root
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
    interactiveShellInit = ''
      # --- NixOS generations helper ---
      alias nixgens='nix-env -p /nix/var/nix/profiles/system --list-generations'

      # Hapus semua generasi lama (kecuali yang aktif) + bersihkan /nix/store.
      # Buat VPS disk/memory kecil.
      nixclean() {
        echo "Hapus semua generasi lama + collect garbage? (y/N)"
        read -r confirmation
        [[ "$confirmation" == y* ]] || { echo "batal"; return 1; }
        nix-env -p /nix/var/nix/profiles/system --delete-generations old
        nix-collect-garbage -d
        echo "selesai. generasi yang tersisa:"
        nix-env -p /nix/var/nix/profiles/system --list-generations
      }
    '';
  };

  # nix-ld: biar binary prebuilt non-nix (python/uv hermes-agent, rtk, dll.)
  # bisa jalan di NixOS
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
    ];
  };

  users.users.root = {
    shell = pkgs.zsh;
    # Password root tidak ada di config ini (publik!). root login pakai SSH
    # key. Password shadow yang tersisa dari install awal dirotasi manual
    # atau dihapus via `passwd -d root` bila VNC darurat tak diperlukan.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuZ1G10ccT9UXtLOVbrqjqSv+/oEdz3ofM7GicHPDG1 rohmadarifin007@gmail.com"
    ];
  };

  # Auto-GC mingguan biar /nix/store gak nge-swell di disk kecil
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  zramSwap.enable = true;

  system.stateVersion = "25.05";
}
