{
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:
# v0.6.1 on purpose: job-hooker's Bayt/Indeed connectors need the exact
# `safari15_5` and `ff117` profiles. nixpkgs ships a newer build that dropped
# `safari15_5` (only safari153), which makes the Bayt connector fail.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "curl-impersonate";
  version = "0.6.1";

  src = fetchurl {
    url = "https://github.com/lwthiker/curl-impersonate/releases/download/v${finalAttrs.version}/curl-impersonate-v${finalAttrs.version}.x86_64-linux-gnu.tar.gz";
    hash = "sha256-+h4WFPe6aczGZyGg84vkV6NkfrZMddZpdLVhhuMxaxI=";
  };

  # The release tarball is a flat directory of wrapper scripts plus their
  # libcurl builds. The binaries are dynamically linked against libz only;
  # autoPatchelf fixes the interpreter/rpath for NixOS.
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ zlib ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/curl_* $out/bin/curl-impersonate-*
    patchShebangs $out/bin
    runHook postInstall
  '';

  meta = {
    description = "curl with browser TLS/JA3 fingerprints (v0.6.1 profiles)";
    homepage = "https://github.com/lwthiker/curl-impersonate";
    platforms = [ "x86_64-linux" ];
  };
})
