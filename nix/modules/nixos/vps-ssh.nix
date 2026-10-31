{ pkgs, inputs, ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
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
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
      "github.com/ecdsa" = {
        hostNames = [ "github.com" ];
        publicKey =
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";
      };
      "github.com/rsa" = {
        hostNames = [ "github.com" ];
        publicKey =
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      };
    };
    extraConfig = ''
      Host github.com
        IdentityFile /root/.ssh/id_ed25519
        IdentitiesOnly yes
    '';
  };

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuZ1G10ccT9UXtLOVbrqjqSv+/oEdz3ofM7GicHPDG1 rohmadarifin007@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB4SA84BWJ39p/H2/bwbXnDDj3DMGYFKq6UTfpJ23xaQ termius"
    ];
  };

  environment.etc."profile.d/nine-router.sh".source =
    "${inputs.self}/nix/scripts/nine-router-env.sh";

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  zramSwap.enable = true;

  system.stateVersion = "25.05";
}
