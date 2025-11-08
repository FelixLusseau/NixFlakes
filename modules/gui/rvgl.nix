{ lib
, stdenv
, fetchzip
, autoPatchelfHook
, makeWrapper
, SDL2
, SDL2_image
, SDL2_mixer
, libGL
, libX11
, libXext
, libXrandr
, libXi
, libXcursor
, libXinerama
, libXxf86vm
, alsa-lib
, libvorbis
, flac
, fluidsynth
}:

stdenv.mkDerivation rec {
  pname = "rvgl";
  version = "23.1030a";

  src = fetchzip {
    url = "https://distribute.re-volt.io/releases/rvgl_full_linux_original.zip";
    sha256 = "sha256-wDCVhyU7d79OeEsLwFYM1e280YBPOFAvRcBcZSM7/Bw=";
    stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    libGL
    libX11
    libXext
    libXrandr
    libXi
    libXcursor
    libXinerama
    libXxf86vm
    alsa-lib
    libvorbis
    flac
    fluidsynth
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    # Créer la structure de répertoires
    mkdir -p $out/bin
    mkdir -p $out/share/rvgl
    mkdir -p $out/share/icons/hicolor/{16x16,24x24,32x32,48x48,256x256}/apps
    mkdir -p $out/share/applications

    # Copier l'exécutable approprié selon l'architecture
    ${if stdenv.hostPlatform.system == "x86_64-linux" then ''
      install -Dm755 rvgl.64 $out/share/rvgl/rvgl
      # Copier les bibliothèques spécifiques
      mkdir -p $out/share/rvgl/lib
      cp -r lib/lib64/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "i686-linux" then ''
      install -Dm755 rvgl.32 $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r lib/lib32/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "aarch64-linux" then ''
      install -Dm755 rvgl.arm64 $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r lib/libarm64/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "armv7l-linux" then ''
      install -Dm755 rvgl.armhf $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r lib/libarmhf/* $out/share/rvgl/lib/
    '' else
      throw "Unsupported platform: ${stdenv.hostPlatform.system}"
    }

    # Copier tous les fichiers de données (voitures, pistes, etc.)
    cp -r cars levels gfx strings wavs edit gallery models redbook cups licenses packs shaders $out/share/rvgl/ 2>/dev/null || true
    cp -r fonts skins music sfx profiles $out/share/rvgl/ 2>/dev/null || true
    cp *.txt *.ini $out/share/rvgl/ 2>/dev/null || true

    # Copier les icônes
    for size in 16x16 24x24 32x32 48x48 256x256; do
      if [ -f icons/$size/apps/rvgl.png ]; then
        install -Dm644 icons/$size/apps/rvgl.png \
          $out/share/icons/hicolor/$size/apps/rvgl.png
      fi
    done

    # Créer un fichier .desktop
    cat > $out/share/applications/rvgl.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=RVGL
    Comment=Re-Volt Game Launcher
    Exec=rvgl
    Icon=rvgl
    Categories=Game;ArcadeGame;
    Terminal=false
    EOF

    # Créer un script wrapper qui gère le répertoire utilisateur
    cat > $out/bin/rvgl-wrapper <<'WRAPPER'
    #!/bin/sh
    RVGL_HOME="$HOME/.rvgl"
    RVGL_DATA="@out@/share/rvgl"
    
    # Créer le répertoire utilisateur s'il n'existe pas
    if [ ! -d "$RVGL_HOME" ]; then
      mkdir -p "$RVGL_HOME"
      # Créer des liens symboliques vers les données en lecture seule
      for dir in cars levels gfx strings wavs edit gallery models redbook cups licenses packs shaders; do
        if [ -d "$RVGL_DATA/$dir" ]; then
          ln -sf "$RVGL_DATA/$dir" "$RVGL_HOME/"
        fi
      done
      # Copier les fichiers de configuration
      for file in "$RVGL_DATA"/*.txt "$RVGL_DATA"/*.ini; do
        if [ -f "$file" ]; then
          cp "$file" "$RVGL_HOME/" 2>/dev/null || true
        fi
      done
    fi
    
    cd "$RVGL_HOME"
    export LD_LIBRARY_PATH="$RVGL_DATA/lib:$LD_LIBRARY_PATH"
    exec "$RVGL_DATA/rvgl" "$@"
    WRAPPER
    
    sed -i "s|@out@|$out|g" $out/bin/rvgl-wrapper
    chmod +x $out/bin/rvgl-wrapper
    
    # Créer le lien final
    ln -s $out/bin/rvgl-wrapper $out/bin/rvgl

    runHook postInstall
  '';

  meta = with lib; {
    description = "Re-Volt GL - Enhanced Re-Volt game engine";
    longDescription = ''
      RVGL is an enhanced Re-Volt game engine with improved graphics,
      online multiplayer support, and modern platform compatibility.
    '';
    homepage = "https://rvgl.org/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    maintainers = [ ];
    mainProgram = "rvgl";
  };
}
