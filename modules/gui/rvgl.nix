{ lib
, stdenv
, fetchFromGitLab
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
  version = "23.1030a1";

  # Récupérer les binaires depuis GitLab
  platform = fetchFromGitLab {
    owner = "re-volt";
    repo = "rvgl-platform";
    rev = version;
    sha256 = "sha256-OlCNBUbyu/hA75qk27xSldjKXsPyaGLXxthtogdmfkQ=";
  };

  # Récupérer les assets depuis GitLab
  assets = fetchFromGitLab {
    owner = "re-volt";
    repo = "rvgl-assets";
    rev = version;
    sha256 = "sha256-9CARqvRS2+r9T+s3uWE7PZLiPluypH8eOOUEGr9S8UQ=";
  };

  # Pas de src car on construit à partir de plusieurs sources
  dontUnpack = true;

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

    mkdir -p $out/bin
    mkdir -p $out/share/rvgl

    # Copier les binaires selon l'architecture
    ${if stdenv.hostPlatform.system == "x86_64-linux" then ''
      install -Dm755 ${platform}/linux/rvgl.64 $out/share/rvgl/rvgl
      # Copier les bibliothèques spécifiques
      mkdir -p $out/share/rvgl/lib
      cp -r ${platform}/linux/lib/lib64/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "i686-linux" then ''
      install -Dm755 ${platform}/linux/rvgl.32 $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r ${platform}/linux/lib/lib32/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "aarch64-linux" then ''
      install -Dm755 ${platform}/linux/rvgl.arm64 $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r ${platform}/linux/lib/libarm64/* $out/share/rvgl/lib/
    '' else if stdenv.hostPlatform.system == "armv7l-linux" then ''
      install -Dm755 ${platform}/linux/rvgl.armhf $out/share/rvgl/rvgl
      mkdir -p $out/share/rvgl/lib
      cp -r ${platform}/linux/lib/libarmhf/* $out/share/rvgl/lib/
    '' else
      throw "Unsupported platform: ${stdenv.hostPlatform.system}"
    }

    # Copier tous les assets
    cp -r ${assets}/* $out/share/rvgl/

    # Copier les icônes
    mkdir -p $out/share/icons/hicolor
    for size in 16x16 24x24 32x32 48x48 256x256; do
      if [ -d ${assets}/icons/$size/apps ]; then
        mkdir -p $out/share/icons/hicolor/$size/apps
        cp ${assets}/icons/$size/apps/*.png $out/share/icons/hicolor/$size/apps/ 2>/dev/null || true
      fi
    done

    # Créer un fichier .desktop
    mkdir -p $out/share/applications
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

    # Créer le script wrapper
    cat > $out/bin/rvgl-wrapper <<'WRAPPER'
    #!/bin/sh
    RVGL_HOME="$HOME/.rvgl"
    RVGL_DATA="@out@/share/rvgl"
    
    # Créer le répertoire utilisateur s'il n'existe pas
    if [ ! -d "$RVGL_HOME" ]; then
      mkdir -p "$RVGL_HOME"
      # Créer des liens symboliques vers les données en lecture seule
      for dir in cars levels gfx strings gallery models licenses packs shaders; do
        if [ -d "$RVGL_DATA/$dir" ]; then
          ln -sf "$RVGL_DATA/$dir" "$RVGL_HOME/"
        fi
      done
      # Copier les fichiers de configuration
      for file in "$RVGL_DATA"/*.txt "$RVGL_DATA"/*.ini "$RVGL_DATA"/*.rpl; do
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
      Built from GitLab repositories with version ${version}.
    '';
    homepage = "https://rvgl.org/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    maintainers = [ ];
    mainProgram = "rvgl";
  };
}
