{
  modulesPath,
  pkgs,
  ezModules,
  inputs,
  ...
}:

let
  npmCli = pkgs.callPackage "${inputs.self}/nix/packages/npm-cli.nix" { };
  # CLI `9router` interaktif (menu web/TUI/tray) — tanpa TTY dia auto exit.
  # Jadi systemd nge-run Next.js server-nya langsung.
  nineRouterApp = "${npmCli."9router"}/lib/node_modules/9router/app";
in
{
  imports = [
    ezModules.vps-disko
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.grub = {
    device = "/dev/vda";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.kernelParams = [ "net.ifnames=0" ];

  networking = {
    hostName = "vps";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    useNetworkd = true;
    defaultGateway = {
      address = "10.11.24.1";
      interface = "eth0";
    };
    nameservers = [
      "183.60.82.98"
      "8.8.8.8"
    ];
    interfaces.eth0 = {
      ipv4.addresses = [
        {
          address = "10.11.26.201";
          prefixLength = 22;
        }
      ];
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

  environment.variables.SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  environment.variables.SSL_CERT_DIR = "/etc/ssl/certs";

  environment.systemPackages = with pkgs; [
    git
    fastfetch
    btop
    neovim
    python3
    nodejs

    # Router LLM = backend 9router buat hermes. Config & API-key
    # provider-nya di /root/.9router (diisi manual, tidak di repo).
    npmCli."9router"

    # hermes-agent + rtk terpasang imperatif di /root/.local/bin
    (pkgs.writeShellScriptBin "hermes" ''
      exec /root/.local/bin/hermes "$@"
    '')
    (pkgs.writeShellScriptBin "rtk" ''
      exec /root/.local/bin/rtk "$@"
    '')
  ];

  # 9router sebagai daemon; bind 127.0.0.1 (yang nembak cuma hermes di
  # host yang sama, gak usah dibuka ke internet).
  systemd.services.nine-router = {
    description = "9router LLM gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.nodejs_24}/bin/node --dns-result-order=ipv4first ${nineRouterApp}/custom-server.js";
      WorkingDirectory = nineRouterApp;
      Environment = [
        "HOME=/root"
        "PORT=20128"
        "HOSTNAME=127.0.0.1"
        "NODE_ENV=production"
        "PATH=/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Alias & config git yang sama kayak laptop (home shell ngga ada di VPS).
  # NOTE: alias git JANGAN diawali "git " — `git gb` jadi `git <value>`.
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "arifinoid";
        email = "rohmadarifin007@gmail.com";
      };
      aliases = {
        gpo = "pull origin";
        ggpo = "push origin";
        gcm = "checkout main";
        gc = "checkout";
        gr = "restore";
        gst = "status";
        gsta = "stash";
        gstl = "stash list";
        gstp = "stash pop";
        gf = "fetch";
        gb = "branch";
        gm = "merge";
        gpom = "pull origin main";
        grv = "remote -v";
      };
    };
  };

  # Hermes baca key 9router dari env NINE_ROUTER_API_KEY; nilainya diambil
  # dari file runtime /root/.9router/hermes-api-key (JANGAN ditaruh di repo).
  environment.etc."profile.d/nine-router.sh".source = "${inputs.self}/nix/scripts/nine-router-env.sh";

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
    interactiveShellInit = ''
      # Key API 9router buat hermes (dibaca dari file runtime, bukan repo).
      if [ -r /root/.9router/hermes-api-key ]; then
        export NINE_ROUTER_API_KEY="$(cat /root/.9router/hermes-api-key)"
      fi

      # Alias daily dari shell laptop (herdr/yarn/pnpm gak relevan di VPS).
      alias vim='nvim'
      alias cl='clear'

      alias nb='nix build'
      alias ndp='nix develop'
      alias nf='nix flake'
      alias nr='nix run'
      alias ns='nix-shell'
      alias nq='nix search'
      alias ngd='nix-collect-garbage -d'
      alias lenv='nix-env -p /nix/var/nix/profiles/system --list-generations'
      alias senv='nix-env -p /nix/var/nix/profiles/system --switch-generation'
      alias denv='nix-env -p /nix/var/nix/profiles/system --delete-generations'

      alias gaa='git add .'
      alias gca='git commit --amend'
      alias gcan='git commit --amend --no-edit'
      alias gcano='git commit --amend --no-edit --no-verify'
      alias gcl='git clone'
      alias gs='git diff'
      alias gfp='git fetch --prune-tags --prune'

      alias nixgens='nix-env -p /nix/var/nix/profiles/system --list-generations'

      # Delete old generations + collect garbage (disk/memory kecil).
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuZ1G10ccT9UXtLOVbrqjqSv+/oEdz3ofM7GicHPDG1 rohmadarifin007@gmail.com"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  zramSwap.enable = true;

  system.stateVersion = "25.05";
}
