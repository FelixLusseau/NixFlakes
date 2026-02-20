{
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
  electron,
  nodePackages,
}:

let
  version = "7.1.70";
  # nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.1.70/deezer-desktop-7.1.70-x64.tar.xz --json | jq -r .hash && nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.1.70/deezer-desktop-7.1.70-arm64.tar.xz --json | jq -r .hash
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
      hash = "sha256-N2WoG8yDFnUghDiLPXX4/I9o05h48P027Vr5N7G4k+M=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-arm64.tar.xz";
      hash = "sha256-6wQVBQK0hUrYCOLqQYCUdoku3Vkta9OCHf6ZUVhjtPc=";
    };
  };

  src = srcs.${stdenv.hostPlatform.system} or (throw "${stdenv.hostPlatform.system} not supported");

  # Architecture string for directory names
  archDir =
    if stdenv.hostPlatform.isx86_64 then
      "x64"
    else if stdenv.hostPlatform.isAarch64 then
      "arm64"
    else
      throw "Unsupported architecture";
in

stdenv.mkDerivation (finalAttrs: {
  pname = "deezer-desktop";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
    nodePackages.asar
  ];

  sourceRoot = ".";

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -d $out/bin $out/share/deezer-desktop/resources $out/share/applications $out/share/icons/hicolor/scalable/apps

    substituteInPlace deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop \
      --replace-fail "run.sh" "deezer-desktop" \
      --replace-fail "dev.aunetx.deezer" "deezer-desktop"
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop $out/share/applications/deezer-desktop.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.svg $out/share/icons/hicolor/scalable/apps/deezer-desktop.svg

    cp deezer-desktop-${version}-${archDir}/resources/app.asar* $out/share/deezer-desktop/resources/
    cp -r deezer-desktop-${version}-${archDir}/resources/linux $out/share/deezer-desktop/resources/
    cp deezer-desktop-${version}-${archDir}/resources.pak $out/share/deezer-desktop/

    # # process.resourcesPath points to Electron's own resources dir when using system Electron.
    # # Replace it with the actual app resources path directly in the bundle.
    # asar extract "$out/share/deezer-desktop/resources/app.asar" "$TMPDIR/asar-unpacked"
    # substituteInPlace "$TMPDIR/asar-unpacked/build/main.js" \
    #   --replace-fail "process.resourcesPath" "\"$out/share/deezer-desktop/resources\""
    # asar pack "$TMPDIR/asar-unpacked" "$out/share/deezer-desktop/resources/app.asar"

    makeWrapper "${lib.getExe electron}" "$out/bin/deezer-desktop" \
      --inherit-argv0 \
      --add-flags "$out/share/deezer-desktop/resources/app.asar" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1

    runHook postInstall
  '';

  meta = {
    description = "Unofficial Linux port of the music streaming application";
    homepage = "https://github.com/aunetx/deezer-linux";
    downloadPage = "https://github.com/aunetx/deezer-linux/releases";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ FelixLusseau ];
    mainProgram = "deezer-desktop";
  };
})
