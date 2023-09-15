{ pkgs }:
{
  # `nix develop my`.
  default = pkgs.mkShell {
    description = "arifinoid/nixpkgs development environment";
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
