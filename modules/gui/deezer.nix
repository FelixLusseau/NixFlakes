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

let
  version = "7.0.190";
  # nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.0.190/deezer-desktop-7.0.190-x64.tar.xz --json | jq -r .hash && nix store prefetch-file https://github.com/aunetx/deezer-linux/releases/download/v7.0.190/deezer-desktop-7.0.190-arm64.tar.xz --json | jq -r .hash
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-x64.tar.xz";
      hash = "sha256-zbkoOhuaayF5GXQNh1P67JpkyhlJqJao+UEvTLMTF1Q=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/aunetx/deezer-linux/releases/download/v${version}/deezer-desktop-${version}-arm64.tar.xz";
      hash = "sha256-mlow0nMW6miJDK95GuGdmccwP83pRddF8hYVUeyDds4="; 
    };
  };
  
  src = srcs.${stdenv.hostPlatform.system}
    or (throw "${stdenv.hostPlatform.system} not supported");
    
  # Architecture string for directory names
  archDir = if stdenv.hostPlatform.isx86_64 then "x64" 
           else if stdenv.hostPlatform.isAarch64 then "arm64"
           else throw "Unsupported architecture";
in

stdenv.mkDerivation rec {
  pname = "deezer";
  inherit version src;

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

    sed -i 's/run\.sh/deezer/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    sed -i 's/dev.aunetx.deezer/deezer/g' deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.desktop $out/share/applications/deezer.desktop
    cp deezer-desktop-${version}-${archDir}/resources/dev.aunetx.deezer.svg $out/share/icons/hicolor/scalable/apps/deezer.svg

    cp -r deezer-desktop-${version}-${archDir} $out/opt/
    chmod -R 755 $out/opt/deezer-desktop-${version}-${archDir}
    ln -s $out/opt/deezer-desktop-${version}-${archDir}/deezer-desktop $out/bin/deezer
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Deezer is a music streaming service";
    homepage = "https://github.com/aunetx/deezer-linux";
    downloadPage = "https://github.com/aunetx/deezer-linux/releases";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.unfree;
    maintainers = with maintainers; [ FelixLusseau ];
    mainProgram = "deezer";
  };
}