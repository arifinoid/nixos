{ pkgs, config, ... }:
let
  pullhead = "git pull origin (git rev-parse --abbrev-ref HEAD)";
  pushhead = "git push origin (git rev-parse --abbrev-ref HEAD)";

  shellAliases = {
    vim = "nvim";
    lenv = "nix-env --list-generations";
    senv = "nix-env --switch-generation";
    denv = "nix-env --delete-generations";
    nb = "nix build";
    ndp = "nix develop";
    nf = "nix flake";
    nr = "nix run";
    ns = "nix-shell";
    nq = "nix search";
    ngd = "nix-collect-garbage -d";
    nxbw = "sudo nixos-rebuild switch --flake .#wsl-arifinoid";
    nxb = "sudo nixos-rebuild switch --flake .#arifinoid";

    # node related
    ys = "yarn start";
    ysb = "yarn start-backend";
    yd = "yarn dev";
    yd- = "yarn develop --watch-admin";
    yb = "yarn build";
    yof = "yarn build && yarn workspace @efishery/theme build && yarn workspace @efishery/onefish build && yarn workspace @efishery/onefish-docs dev";
    yall = "yarn workspace @efishery/onefish build && yarn workspace @efishery/theme build && yarn workspace @efishery/components build && yarn workspace @efishery/onefish-docs dev";
    yt = "yarn test";
    yse = "yarn server";
    yw = "yarn workspace";
    ywa = "yarn workspace @apps/area";
    ywp = "yarn workspace @apps/point";
    ywr = "yarn workspace @apps/region";
    yco = "yarn cypress:open";
    ytc = "yarn test:chrome";
    ytf = "yarn test:firefox";

    prd = "pnpm run dev";

    cl = "clear";
    cds = "find . -name '.DS_Store' -type f -delete";
    absen = "colima start && docker compose up";
  };

  shellAbbrs = {
    cat = "bat";
    rm = "trash";

    # git
    gaa = "git add .";
    gb = "git branch";
    gc = "git checkout";
    gca = "git commit --amend";
    gcan = "git commit --amend --no-edit";
    gcano = "git commit --amend --no-edit --no-verify";
    gcl = "git clone";
    gcm = "git checkout master";
    gs = "git diff";
    gf = "git fetch";
    gfp = "git fetch --prune-tags --prune";
    ggpo = "git push origin";
    gm = "git merge";
    gpo = "git pull origin";
    gpom = "git pull origin master";
    gr = "git restore";
    grv = "git remote -v";
    gst = "git status";
    gsta = "git stash";
    gstl = "git stash list";
    gstp = "git stash pop";
    tarek = pullhead;
    gas = pushhead;
    gascok = "${pushhead} --force";

    # node related
    clearnode = "find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +";
    findnode = "find . -name 'node_modules' -type d -prune";
    fixnodegyp = "npm explore npm/node_modules/@npmcli/run-script -g -- npm_config_global=false npm install node-gyp@latest";

    # warp
    wcc = "warp-cli connect";
    wccheck = "curl https://www.cloudflare.com/cdn-cgi/trace";
    wcd = "warp-cli disconnect";

    # vpn
    ovpnall = "sudo openvpn --config ~/Downloads/efi-rohmad/efi-platform_efi-rohmad_allaccess.ovpn";
    ovpnpre = "sudo openvpn --config ~/Downloads/efi-rohmad/efi-platform_efi-rohmad_pre-production.ovpn";
    gcpvpnpre = "sudo openvpn --config ~/Downloads/efi-rohmad/gcp-platform-preproduction_efi-rohmad_eng-preproduction.ovpn";

    # container
    drnt = "docker rmi $(docker images --filter \"dangling=true\" -q --no-trunc)";
    dpf = "docker system prune --all --force";

    # notes
    obside = "~/Downloads/Obsidian-1.5.8.AppImage";
  };
in
{
  home = with pkgs; {
    shellAliases = shellAliases;
    sessionPath = [ "$HOME/.yarn/bin" ];
    packages = with fishPlugins; [
      pay-respects # the fuck replacement
      foreign-env
      forgit # https://github.com/wfxr/forgit
      pisces # Paired symbols in the command line
    ];
  };

  programs = {
    dircolors.enable = true;
    fish = {
      enable = true;
      shellAbbrs = shellAbbrs;
      shellAliases = shellAliases;
      shellInit = ''
          if status is-interactive
            if not set -q TMUX
              tmux attach-session -t default 2>/dev/null; or tmux new-session -s default
            end
          end

        # Load API keys from pass if not already set
        if type -q pass
          if not set -q OPENAI_API_KEY
            set -gx OPENAI_API_KEY (pass show arifinoid/openai.api.key 2>/dev/null | head -n1)
          end
          if not set -q ANTHROPIC_API_KEY
            set -gx ANTHROPIC_API_KEY (pass show arifinoid/anthropic.api.key 2>/dev/null | head -n1)
          end
        end

        starship init fish | source
      '';
      plugins = [ ];
      functions = {
        envsource = ''
          for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';
        nix-update = "  nix-channel --update\n  nix flake update\n";
        nix-clean = ''
          nix-env --delete-generations old
          nix-store --gc
          nix-channel --update
          nix-env -u --always
          if test -f /etc/NIXOS
              for link in /nix/var/nix/gcroots/auto/*
                  rm $(readlink "$link")
              end
          end
          nix-collect-garbage -d
        '';
        nix-shell = {
          wraps = "nix-shell";
          body = ''
            for ARG in $argv
              if [ "$ARG" = --run ]
                command nix-shell $argv
                return $status
              end
            end
            command nix-shell $argv --run "exec fish"
          '';
        };
      };
      loginShellInit = ''
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
          fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
        end

        # Ensure API keys are present in login shells
        if type -q pass
          if not set -q OPENAI_API_KEY
            set -gx OPENAI_API_KEY (pass show arifinoid/openai.api.key 2>/dev/null | head -n1)
          end
          if not set -q ANTHROPIC_API_KEY
            set -gx ANTHROPIC_API_KEY (pass show arifinoid/anthropic.api.key 2>/dev/null | head -n1)
          end
        end
      '';
      interactiveShellInit = ''
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
          fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
        end

        # Ensure API keys are present in interactive shells
        if type -q pass
          if not set -q OPENAI_API_KEY
            set -gx OPENAI_API_KEY (pass show arifinoid/openai.api.key 2>/dev/null | head -n1)
          end
          if not set -q ANTHROPIC_API_KEY
            set -gx ANTHROPIC_API_KEY (pass show arifinoid/anthropic.api.key 2>/dev/null | head -n1)
          end
        end

        if status is-interactive
        and not set -q TMUX
            exec tmux
        end
      '';
    };
    starship = {
      enable = true;
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
    };
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Dracula";
      };
    };
    eza = {
      enable = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
    };
  };
}
