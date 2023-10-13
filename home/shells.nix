{ pkgs, ... }:
let
  commandFoldl' = builtins.foldl' (a: b: a + b + '' &&'') '''';
  shellAliases = {
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
    nclean = commandFoldl' [
      "nix profile wipe-history"
      "nix-collect-garbage"
      "nix-collect-garbage -d"
      "nix-collect-garbage --delete-old"
      "nix store gc"
      "nix store optimise"
      "nix-store --verify --repair --check-contents"
    ];

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
    vim = "nvim";
  };

  shellAbbrs = {
    cat = "bat";
    rm = "trash";
    # git
    gaa = "git add .";
    gb = "git branch";
    gc = "git checkout";
    gcl = "git clone";
    gcm = "git checkout master";
    gs = "git diff";
    gf = "git fetch";
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
  };
in
{
  home = with pkgs; {
    shellAliases = shellAliases;
    sessionPath = [
      "$HOME/.yarn/bin"
    ];
    packages = with fishPlugins;[
      thefuck
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
      plugins = [
        {
          name = "z";
          src = pkgs.fetchFromGitHub {
            owner = "jethrokuan";
            repo = "z";
            rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
            sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
          };
        }
        {
          name = "done";
          src = pkgs.fetchFromGitHub {
            owner = "franciscolourenco";
            repo = "done";
            rev = "1.16.5";
            sha256 = "E0wveeDw1VzEH2kzn63q9hy1xkccfxQHBV2gVpu2IdQ=";
          };
        }
        {
          name = "pisces";
          src = pkgs.fetchFromGitHub {
            owner = "laughedelic";
            repo = "pisces";
            rev = "v0.7.0";
            sha256 = "sha256-Oou2IeNNAqR00ZT3bss/DbhrJjGeMsn9dBBYhgdafBw=";
          };
        }
        {
          name = "foreign-env";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-foreign-env";
            rev = "dddd9213272a0ab848d474d0cbde12ad034e65bc";
            sha256 = "00xqlyl3lffc5l0viin1nyp819wf81fncqyz87jx8ljjdhilmgbs";
          };
        }
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
          };
        }
        {
          name = "thefuck";
          src = pkgs.fetchFromGitHub
            {
              owner = "oh-my-fish";
              repo = "plugin-thefuck";
              rev = "6c9a926d045dc404a11854a645917b368f78fc4d";
              sha256 = "1n6ibqcgsq1p8lblj334ym2qpdxwiyaahyybvpz93c8c9g4f9ipl";
            };
        }
      ];
      functions = {
        envsource = ''
          for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
            set item (string split -m 1 '=' $line)
            set -gx $item[1] $item[2]
            echo "Exported key $item[1]"
          end
        '';
      };
      loginShellInit = ''
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
          fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
        end
      '';
      interactiveShellInit = ''
        ${pkgs.thefuck}/bin/thefuck --alias | source

        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
          fenv source '/nix/var/nix/profiles/default/etc/profile.d/nix.sh'
        end
      '';
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Dracula";
      };
    };
    exa = {
      enable = true;
      enableAliases = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };
}
