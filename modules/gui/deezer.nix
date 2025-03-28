{ stdenv, lib
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
  version = "7.0.40";

  src = fetchurl {
    url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
    hash = "sha256-JbEYcpOt7rTJSAaL/wv6Oyb0UNTOmiDmGdT3m1fcjw0=";
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
    # install -m755 -D deezer-desktop-${version}-x64/deezer-desktop $out/bin/deezer
    install -d $out/bin
    cp -r deezer-desktop-${version}-x64 $out/bin/
    chmod -R 755 $out/bin/deezer-desktop-${version}-x64
    ln -s $out/bin/deezer-desktop-${version}-x64/deezer-desktop $out/bin/deezer
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/aunetx/deezer-linux";
    description = "Deezer is a music streaming service";
    platforms = platforms.linux;
  };
}