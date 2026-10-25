# CLI agent yang binary-nya diambil dari GitHub release (nixpkgs gak punya):
# rtk & icm. Dipakai asset musl (statis) dari release resmi, jadi:
#   - start instan tanpa compile Rust,
#   - aman di NixOS tanpa nix-ld ( Linking glibc builtin gak kepakai),
#   - hash = sha256 dari checksums.txt di halaman release yang sama.
#
# Cara bump versi:
#   1. Buka release terbaru, ambil sha256 asset x86_64-unknown-linux-musl.tar.gz
#      dari checksums.txt.
#   2. Update version + hash di bawah.
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
