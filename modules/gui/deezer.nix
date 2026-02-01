{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  gcc-unwrapped,
  cairo,
  pango,
  gtk3,
  nss,
  libdrm,
  alsa-lib,
  libgbm,
  libglvnd,
}:

let
  version = "7.1.50";
  # nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.0.190/deezer-desktop-7.0.190-x64.tar.xz --json | jq -r .hash && nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.0.190/deezer-desktop-7.0.190-arm64.tar.xz --json | jq -r .hash
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
      hash = "sha256-8Tmj/Z2Cok+PTmcwNQzkKcct+T6qRFjRoiOrfURZKrY=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-arm64.tar.xz";
      hash = "sha256-fn5XkGj4LZKZ9RiBuoMlQeHOo8//3XOIhI3Dp58DTjk=";
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
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gcc-unwrapped
    cairo
    pango
    gtk3
    nss
    libdrm
    alsa-lib
    libgbm
    libglvnd
  ];

  sourceRoot = ".";

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -d $out/bin $out/opt $out/share $out/share/applications $out/share/icons/hicolor/scalable/apps

    sed -i 's/run\.sh/deezer/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    sed -i 's/dev.aunetx.deezer/deezer/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop $out/share/applications/deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.svg $out/share/icons/hicolor/scalable/apps/deezer.svg

    cp -r deezer-desktop-${version}-${archDir} $out/opt/
    chmod -R 755 $out/opt/deezer-desktop-${version}-${archDir}

    # Create wrapper with proper library paths
    makeWrapper $out/opt/deezer-desktop-${version}-${archDir}/deezer-desktop $out/bin/deezer \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}"

    runHook postInstall
  '';

  meta = {
    description = "Deezer is a music streaming service";
    homepage = "https://github.com/aunetx/deezer-linux";
    downloadPage = "https://github.com/aunetx/deezer-linux/releases";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ FelixLusseau ];
    mainProgram = "deezer";
  };
})
