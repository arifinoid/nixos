{ pkgs, ... }:
{
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
}
