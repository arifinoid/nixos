# Agent CLIs whose binaries come from GitHub releases (not in nixpkgs):
# rtk & icm. They use the static musl assets from the official releases, so:
#   - instant startup with no Rust compile,
#   - safe on NixOS without nix-ld (the glibc builtin is not used),
#   - hash = sha256 from checksums.txt on the same release page.
#
# To bump a version:
#   1. Open the latest release and take the sha256 of the
#      x86_64-unknown-linux-musl.tar.gz asset from checksums.txt.
#   2. Update version + hash below.
{
  lib,
  fetchurl,
  stdenvNoCC,
  gnutar,
}:

let
  mkReleaseCli =
    {
      pname,
      version,
      releaseTag,
      asset,
      hash,
    }:
    stdenvNoCC.mkDerivation {
      inherit pname version;
      src = fetchurl {
        url = "https://github.com/rtk-ai/${pname}/releases/download/${releaseTag}/${asset}";
        inherit hash;
      };
      dontBuild = true;
      dontUnpack = true;
      nativeBuildInputs = [ gnutar ];
      installPhase = ''
        runHook preInstall
        tar -xzf $src
        install -Dm755 ${pname} $out/bin/${pname}
        runHook postInstall
      '';
      meta = {
        description = "${pname} agent CLI (prebuilt musl release)";
        homepage = "https://github.com/rtk-ai/${pname}";
        license = lib.licenses.mit;
        mainProgram = pname;
        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      };
    };
in
rec {
  rtk = mkReleaseCli {
    pname = "rtk";
    version = "1.0.1";
    releaseTag = "v1.0.1";
    asset = "rtk-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-W5GcO8y3mbZ6YYZtDmF0EKT83xc+JhREDlneL6IANDY=";
  };

  icm = mkReleaseCli {
    pname = "icm";
    version = "0.11.4";
    releaseTag = "icm-v0.11.4";
    asset = "icm-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-VNxXvxZdFIXUgJwqUiPVcZ6WWAGncVQ0iQk5HKhRx/4=";
  };
}
