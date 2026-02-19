{
  stdenv,
  lib,
  fetchurl,
  makeWrapper,
  electron,
  nodePackages,
}:

let
  version = "7.1.60";
  # nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.1.60/deezer-desktop-7.1.60-x64.tar.xz --json | jq -r .hash && nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.1.60/deezer-desktop-7.1.60-arm64.tar.xz --json | jq -r .hash
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
      hash = "sha256-+vgvW036DQBmxpZ3ftbZdBh4uLK/LIQe2DEzmkYT518=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-arm64.tar.xz";
      hash = "sha256-gHtiorZi/pQBkh7unaQsVgsOlwb2wFSMPx0Inhin9kk=";
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
  pname = "deezer";
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

    sed -i 's/run\.sh/deezer-desktop/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    sed -i 's/dev.aunetx.deezer/deezer/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop $out/share/applications/deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.svg $out/share/icons/hicolor/scalable/apps/deezer.svg

    cp deezer-desktop-${version}-${archDir}/resources/app.asar* $out/share/deezer-desktop/resources/
    cp -r deezer-desktop-${version}-${archDir}/resources/linux $out/share/deezer-desktop/resources/

    # process.resourcesPath points to Electron's own resources dir when using system Electron.
    # Replace it with the actual app resources path directly in the bundle.
    asar extract "$out/share/deezer-desktop/resources/app.asar" "$TMPDIR/asar-unpacked"
    sed -i "s|process\.resourcesPath|\"$out/share/deezer-desktop/resources\"|g" \
      "$TMPDIR/asar-unpacked/build/main.js"
    asar pack "$TMPDIR/asar-unpacked" "$out/share/deezer-desktop/resources/app.asar"

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
