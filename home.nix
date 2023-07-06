{ config, pkgs, lib, ... }:

{
  home.username = "arifinoid";
  home.homeDirectory = "/home/arifinoid";
  home.stateVersion = "23.05"; # Please read the comment before changing.
  # home.activation = {
   # defaultShell = lib.hm.dag.entryAfter [
    #    "WriteBoundary"
    #] ''
    #sudo ${pkgs.util-linux}/bin/chsh -s /home/arifinoid/.nix-profile/bin/fish
    #'';
  #};

  home.shellAliases = {
    hmb = "nix build ~/.config/home-manager#homeConfigurations.x86_64-linux.arifinoid.activationPackage -o ~/.config/home-manager/result";
    hmo = "~/.config/home-manager/result/activate";
  };
  home.packages = with pkgs; [
    curl
    neofetch
    ripgrep
    htop
    trash-cli
    openvpn
    openvpn3
    alacritty
    nodejs_20
    yarn
    go
    gcc9
    libstdcxx5
    python39
    git
    lazygit
    nerdfonts
    rustc
    cargo
    zig
    fishPlugins.bass
    speedtest-cli
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];


  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;
  programs.fish = {
    enable = true;
    shellAbbrs = {
      rm = "trash";
      cat = "bat";
    };
    shellAliases = {
      cl = "clear";
#     ls = "ls -p -G";
#     la = "ls -A";
#     ll = "ls -l";
#     lla = "ll -A";
    };
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
    ];
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    plugins = with pkgs.vimPlugins; [
      neovim-sensible
      nvim-surround
      nvim-treesitter
      dracula-nvim
      vim-fugitive
      vim-commentary
    ];
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "Dracula";
    };
  };
  programs.exa = {
    enable = true;
    enableAliases = true;
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
