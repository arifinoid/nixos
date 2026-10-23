# Derivasi CLI npm yang TIDAK ada di nixpkgs.
#
# Semua di-pin ke tarball registry npm + package-lock.json di ./locks/:
# binary masuk /nix/store sehingga start instan + offline, menggantikan
# wrapper npx/bunx yang nge-resolve registry tiap launch (painful abis
# restart laptop).
#
# Cara bump versi:
#   1. `nix shell nixpkgs#nodejs -c npm install <pkg>@<versi>
#      --package-lock-only --omit=dev --ignore-scripts` lalu timpa
#      ./locks/<nama>-lock.json
#   2. Set tarballHash & npmDepsHash ke lib.fakeHash, `nix build`, copy
#      hash "got:" yang muncul ke masing-masing field, rebuild.
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
      nodejs ? pkgs.nodejs_24, # runtime: memenuhi engines rea ^24.11 & omo >=24
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
      postPatch = ''cp ${lock} package-lock.json'';
      inherit
        npmDepsHash
        npmInstallFlags
        npmRebuildFlags
        npmPackFlags
        nodejs
        ;
      dontNpmBuild = true; # tarball registry sudah berisi hasil build (dist)
      # postinstall 9router/omo cuma patch lokal (non-fatal); rea punya
      # optionalDependency frida yang install script-nya butuh net.
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

  # ECC (affaan-m/ECC) — operator layer buat Claude Code & harness lain.
  # CLI-nya dipakai buat doctor/consult/repair/uninstall; skill/agent-nya sendiri
  # di-install sebagai plugin Claude Code (ecc@ecc), bukan lewat paket ini.
  ecc = mkNpmCli {
    pname = "ecc";
    pkg = "ecc-universal";
    version = "2.2.3";
    tarballHash = "sha256-ZRKiTy6zcKn01JqZZuuwSaGRlIrq/il/Y0CjrL68bl0=";
    npmDepsHash = "sha256-d8G66uSQhJYvCQQAKqO2PMJywqxmdC9OuNlTzMHOZqM=";
    lock = ./locks/ecc-universal-lock.json;
    npmInstallFlags = [
      "--omit=dev"
      "--ignore-scripts" # tarball registry sudah berisi hasil build
    ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    # Tarball ECC ke-publish tanpa scripts/build-opencode.js, jadi `prepack`
    # (npm run build:opencode) gagal saat di-run di dalam sandbox nix.
    # Output .opencode/ yang dipublish tetap ikut terbawa, jadi pack cukup
    # tanpa jalankan script sama sekali.
    npmPackFlags = [ "--ignore-scripts" ];
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

  rea = mkNpmCli {
    pname = "rea";
    pkg = "rea-agents";
    version = "6.5.0";
    tarballHash = "sha256-UxcXoG6SymUaq1JpEZD5FvrARCcsAfh14ixeKTIY5pk=";
    npmDepsHash = "sha256-XPxwg4rEBKbqLkccOoZI5QNYLb0cYOcNoIxDqadO0OA=";
    lock = ./locks/rea-agents-lock.json;
    npmInstallFlags = [
      "--omit=dev"
      "--ignore-scripts" # frida (optional dep) butuh net
    ];
    npmRebuildFlags = [ "--ignore-scripts" ];
  };
}
