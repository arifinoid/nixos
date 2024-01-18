{ pkgs }: {
  # `nix develop my`.
  default = pkgs.mkShell {
    description = "arifinoid/nixpkgs development environment";
    shellHook = let
      tmuxConf = pkgs.writeText "tmux.conf"
        "set-option -g default-shell ${pkgs.fish}/bin/fish";
    in ''
      tmux -f ${tmuxConf}
    '';
  };

  node18 = pkgs.mkShell {
    description = "Node.js 18 Development Environment";
    buildInputs = with pkgs; [
      nodejs_18
      (nodePackages.yarn.override { nodejs = nodejs_18; })
    ];
  };

  go = pkgs.mkShell {
    description = "Go development environment";
    buildInputs = with pkgs; [ go ];
  };
}
