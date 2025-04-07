{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, gcc-unwrapped
, cairo
, pango
, gtk3
, nss
, libdrm
, alsa-lib
, libgbm
}:

stdenv.mkDerivation rec {
  pname = "deezer";
  version = "7.0.50";

  src = fetchurl {
    url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
    hash = "sha256-PZQF0vV2nkduK8RW4D93QTtM2GVbniMG3Nukjth/eO8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
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
  ];

  sourceRoot = ".";

  dontBuild = true;
  installPhase = ''
    runHook preInstall
    install -d $out/bin $out/opt $out/share $out/share/applications $out/share/icons/hicolor/scalable/apps

    sed -i 's/run\.sh/deezer/g' deezer-desktop-${version}-x64/resources/dev.aunetx.deezer.desktop
    sed -i 's/dev.aunetx.deezer/deezer/g' deezer-desktop-${version}-x64/resources/dev.aunetx.deezer.desktop
    cp deezer-desktop-${version}-x64/resources/dev.aunetx.deezer.desktop $out/share/applications/deezer.desktop
    cp deezer-desktop-${version}-x64/resources/dev.aunetx.deezer.svg $out/share/icons/hicolor/scalable/apps/deezer.svg

    cp -r deezer-desktop-${version}-x64 $out/opt/
    chmod -R 755 $out/opt/deezer-desktop-${version}-x64
    ln -s $out/opt/deezer-desktop-${version}-x64/deezer-desktop $out/bin/deezer
    
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/aunetx/deezer-linux";
    description = "Deezer is a music streaming service";
    platforms = platforms.linux;
  };
}