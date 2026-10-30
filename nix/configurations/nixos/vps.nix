{
  config,
  modulesPath,
  pkgs,
  ezModules,
  inputs,
  ...
}:

let
  npmCli = pkgs.callPackage "${inputs.self}/nix/packages/npm-cli.nix" { };
  nineRouterApp = "${npmCli."9router"}/lib/node_modules/9router/app";
in
{
  imports = [
    inputs.sops.nixosModules.sops
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
    firewall.allowedTCPPorts = [
      22
      80
      443
    ];
  };

  # Docker
  virtualisation.docker.enable = true;

  # Nginx + reverse proxy ke PM2 (personal web di 127.0.0.1:3000)
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    virtualHosts."arifinoid.web.id" = {
      serverName = "arifinoid.web.id";
      forceSSL = true;
      enableACME = true;
      root = "/var/www/personal-web";
      locations."/" = {
        tryFiles = "$uri $uri/ /index.html";
        extraConfig = "index index.html;";
      };
    };
  };

  # Let's Encrypt via NixOS native ACME (pengganti certbot standalone)
  security.acme = {
    acceptTerms = true;
    certs."arifinoid.web.id" = {
      email = "rohmadarifin007@gmail.com";
      domain = "arifinoid.web.id";
    };
  };

  # Buat direktori web personal
  systemd.tmpfiles.rules = [
    "d /Documents/personal-web 0755 root root -"
    "d /root/Documents/personal-web 0755 root root -"
    "d /var/www 0755 root root -"
    "L+ /var/www/personal-web - - - - /root/Documents/personal-web/out"
  ];

  # Personal web disajikan langsung oleh Nginx (static export di out/).
  # PM2 tetap terpasang untuk kebutuhan lain.

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
    gh
    fastfetch
    btop
    neovim
    python3
    nodejs
    bun
    pm2
    certbot
    nginx

    bat
    eza
    zsh-completions

    npmCli."9router"

    (pkgs.writeShellScriptBin "hermes" ''
      exec /root/.local/bin/hermes "$@"
    '')
    (pkgs.writeShellScriptBin "nine-router-key" ''
      exec ${pkgs.coreutils}/bin/cat /root/.9router/hermes-api-key
    '')
    (pkgs.writeShellScriptBin "rtk" ''
      exec /root/.local/bin/rtk "$@"
    '')
  ];

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
      ExitType = "cgroup";
    };
  };

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

  programs.ssh = {
    knownHosts = {
      "github.com" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "github.com/ecdsa" = {
        hostNames = [ "github.com" ];
        publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
      };
      "github.com/rsa" = {
        hostNames = [ "github.com" ];
        publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      };
    };
    extraConfig = ''
      Host github.com
        IdentityFile /root/.ssh/id_ed25519
        IdentitiesOnly yes
    '';
  };

  environment.etc."profile.d/nine-router.sh".source = "${inputs.self}/nix/scripts/nine-router-env.sh";

  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secret.yaml";
    age.keyFile = "/var/lib/sops-nix/key.txt";
    package = inputs.sops.packages.${pkgs.stdenv.hostPlatform.system}.sops-install-secrets;
    secrets.nine_router_api_key = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
    templates."/root/.9router/hermes-api-key" = {
      name = "root/.9router/hermes-api-key";
      path = "/root/.9router/hermes-api-key";
      content = config.sops.placeholder.nine_router_api_key;
      mode = "0400";
      owner = "root";
      group = "root";
    };
    templates."/root/.config/environment.d/99-nine-router.conf" = {
      name = "root/.config/environment.d/99-nine-router.conf";
      path = "/root/.config/environment.d/99-nine-router.conf";
      content = "NINE_ROUTER_API_KEY=${config.sops.placeholder.nine_router_api_key}";
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableLsColors = true;
    autosuggestions = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
    interactiveShellInit = ''
      # Key API 9router buat hermes, dibaca dari file hasil render sops.
      if [ -r /root/.9router/hermes-api-key ]; then
        export NINE_ROUTER_API_KEY="$(cat /root/.9router/hermes-api-key)"
      fi

      # Alias daily dari shell laptop (herdr/yarn/pnpm gak relevan di VPS).
      alias vim='nvim'
      alias cl='clear'

      # Warna & listing modern.
      alias cat='bat'
      alias ls='eza --group-directories-first'
      alias ll='eza -l --group-directories-first'
      alias la='eza -la --group-directories-first'
      alias lt='eza --tree --level=2'

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

  programs.bat = {
    enable = true;
    settings = {
      pager = "less -FR";
      theme = "Dracula";
    };
  };

  programs.zoxide.enable = true;

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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4SA84BWJ39p/H2/bwbXnDDj3DMGYFKq6UTfpJ23xaQ termius"
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
