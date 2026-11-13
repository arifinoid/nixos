# npm CLI derivations that are NOT in nixpkgs.
#
# Everything is pinned to the npm registry tarball + package-lock.json in
# ./locks/: binaries land in /nix/store, so startup is instant and offline,
# replacing npx/bunx wrappers that resolve the registry on every launch
# (painful after a laptop restart).
#
# To bump a version:
#   1. `nix shell nixpkgs#nodejs -c npm install <pkg>@<version>
#      --package-lock-only --omit=dev --ignore-scripts`, then overwrite
#      ./locks/<name>-lock.json
#   2. Set tarballHash & npmDepsHash to lib.fakeHash, run `nix build`, copy the
#      "got:" hash that appears into each field, rebuild.
{
  lib,
  pkgs,
}:
let
  mkNpmCli =
    {
      pname,
      pkg,
      version,
      tarballHash,
      npmDepsHash,
      lock,
      nodejs ? pkgs.nodejs_24, # runtime: satisfies the engines of rea ^24.11 & omo >=24
      npmInstallFlags ? [ ],
      npmRebuildFlags ? [ ],
      npmPackFlags ? [ ],
    }:
    pkgs.buildNpmPackage {
      inherit pname version;
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/${pkg}/-/${builtins.baseNameOf pkg}-${version}.tgz";
        hash = tarballHash;
      };
      postPatch = "cp ${lock} package-lock.json";
      inherit
        npmDepsHash
        npmInstallFlags
        npmRebuildFlags
        npmPackFlags
        nodejs
        ;
      dontNpmBuild = true;
      strictDeps = true;
      allowSubstitutes = true;
      meta = {
        mainProgram = pname;
        platforms = lib.platforms.all;
      };
    };
in
{
  pi = mkNpmCli {
    pname = "pi";
    pkg = "@earendil-works/pi-coding-agent";
    version = "1.3.0";
    tarballHash = "sha256-rieF6HC4GoyOHURRCle17gv8npdGeawvqq2kqr7j08A=";
    npmDepsHash = "sha256-K3acNHvZ42YQbTe92qWVaYqAP63IPOBuQV9AYbQOqqU=";
    lock = ./locks/pi-coding-agent-lock.json;
    npmInstallFlags = [ "--omit=dev" ];
  };

  "9router" = mkNpmCli {
    pname = "9router";
    pkg = "9router";
    version = "0.5.104";
    tarballHash = "sha256-96CLtldJk9zxVySZhYutnojJNUJiWNh1Hs47/XDzKKc=";
    npmDepsHash = "sha256-pI4dG3HhPWjvVZ6MUY1EEEvvKdSK8F7YHNbei1gj/lc=";
    lock = ./locks/9router-lock.json;
  };

  omo = mkNpmCli {
    pname = "omo";
    pkg = "omo-ai";
    version = "5.1.35";
    tarballHash = "sha256-3uUk6njf185gMRVRZh4r8KvdAlxjcVysXBw+LRKEAaE=";
    npmDepsHash = "sha256-qBFBCWBEAUoZt7h0ENzpbs4Ofm9Y/+lcD+eX6MBYF/8=";
    lock = ./locks/omo-ai-lock.json;
    npmInstallFlags = [ "--omit=dev" ];
  };

  codebuddy = mkNpmCli {
    pname = "codebuddy";
    pkg = "@tencent-ai/codebuddy-code";
    version = "2.177.0";
    tarballHash = "sha256-Nl3bDjeryB222FAuTWNSOF0jJkxDAASUjrw6gsPjiP4=";
    npmDepsHash = "sha256-TcQ8BXj56PKjEZF+9dMQ8DwMXDBoShyRUS8szFqCBkQ=";
    lock = ./locks/codebuddy-code-lock.json;
    npmInstallFlags = [ "--omit=dev" ];
  };

  rea = mkNpmCli {
    pname = "rea";
    pkg = "rea-agents";
    version = "6.5.0";
    tarballHash = "sha256-UxcXoG6SymUaq1JpEZD5FvrARCcsAfh14ixeKTIY5pk=";
    npmDepsHash = "sha256-XPxwg4rEBKbqLkccOoZI5QNYLb0cYOcNoIxDqadO0OA=";
    lock = ./locks/rea-agents-lock.json;
    npmInstallFlags = [
      "--omit=dev"
      "--ignore-scripts" # frida (optional dep) needs network
    ];
    npmRebuildFlags = [ "--ignore-scripts" ];
  };
}
