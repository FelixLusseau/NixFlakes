{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, poco
, cppunit
, sentry-native
, libzip
, openssl
, zlib
, log4cplus
, xxHash
, sqlite
, libsecret
, libGL
, mesa
, freeglut
, glib
, makeWrapper
, nss
, xorg
}:

stdenv.mkDerivation rec {
  pname = "kdrive";
  version = "3.7.9";

  src = fetchFromGitHub {
    owner = "Infomaniak";
    repo = "desktop-kDrive";
    rev = version;
    sha256 = "sha256-1MIiFWxMciTaMOysDo+9dtCbFKfgyXR03SCo4J41rzE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine
    qt6.qtpositioning
    qt6.qtwebchannel
    qt6.qtwebview
    qt6.qt5compat
    qt6.qtwayland
    qt6.qtserialport
    poco
    cppunit
    sentry-native
    libzip
    libzip.dev
    openssl
    zlib
    log4cplus
    xxHash
    sqlite
    libsecret
    libGL
    mesa
    freeglut
    glib
    nss
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilcursor
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
  ];

  postPatch = ''
    # Créer un module FindLog4cplus.cmake minimal
    mkdir -p cmake/modules
    cat > cmake/modules/Findlog4cplus.cmake << 'EOFCMAKE'
if(NOT TARGET log4cplus::log4cplus)
  add_library(log4cplus::log4cplus UNKNOWN IMPORTED)
  set_target_properties(log4cplus::log4cplus PROPERTIES
    IMPORTED_LOCATION "''${log4cplus_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "''${log4cplus_INCLUDE_DIR}"
    INTERFACE_COMPILE_DEFINITIONS "UNICODE"
  )
endif()
set(log4cplus_FOUND TRUE)
set(log4cplus_VERSION "2.1.2")
EOFCMAKE
    
    # Ajouter le chemin du module
    substituteInPlace CMakeLists.txt \
      --replace-fail 'project(client)' \
                     'list(APPEND CMAKE_MODULE_PATH "''${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
project(client)'
    
    # Patcher la copie de bibliothèques pour utiliser les chemins Nix
    substituteInPlace CMakeLists.txt \
      --replace-fail 'get_library_dirs("log4cplus" "log4cplus")' \
                     'set(_log4cplus_LIB_DIRS "${log4cplus}/lib")' \
      --replace-fail 'get_library_dirs("OpenSSL" "openssl")' \
                     'set(_OpenSSL_LIB_DIRS "${openssl.out}/lib")' \
      --replace-fail 'get_library_dirs("xxHash" "xxhash")' \
                     'set(_xxHash_LIB_DIRS "${xxHash}/lib")'
    
    # Remplacer les chemins des variables par les valeurs réelles avec les bons noms de fichiers (utiliser Unicode version)
    substituteInPlace CMakeLists.txt \
      --replace-fail '"''${_log4cplus_LIB_DIRS}/liblog4cplus.so"' '"${log4cplus}/lib/liblog4cplusU.so"' \
      --replace-fail '"''${_log4cplus_LIB_DIRS}/liblog4cplus.so.9"' '"${log4cplus}/lib/liblog4cplusU-2.1.so.9"' \
      --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so"' '"${xxHash}/lib/libxxhash.so"' \
      --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so.0"' '"${xxHash}/lib/libxxhash.so.0"' \
      --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so.0.8.2"' '"${xxHash}/lib/libxxhash.so.0.8.3"'
    
    # Patcher les CMakeLists pour ajouter la configuration RelWithDebInfo pour libzip
    for file in src/libcommon/CMakeLists.txt src/libcommonserver/CMakeLists.txt; do
      substituteInPlace "$file" \
        --replace-fail 'find_package(libzip 1.10.1 REQUIRED)' \
                       'find_package(libzip 1.10.1 REQUIRED)
if(TARGET libzip::zip)
  set_target_properties(libzip::zip PROPERTIES
    IMPORTED_LOCATION_RELWITHDEBINFO "${libzip}/lib/libzip.so"
    IMPORTED_IMPLIB_RELWITHDEBINFO "${libzip}/lib/libzip.so"
  )
endif()'
    done
  '';

  # Créer un répertoire de dépendances vide pour Conan
  preConfigure = ''
    export HOME=$TMPDIR
    mkdir -p build-linux/conan/dependencies
    
    # Créer des liens symboliques vers les dépendances Nix
    ln -sf ${openssl.out}/lib/* build-linux/conan/dependencies/ || true
    ln -sf ${zlib.out}/lib/* build-linux/conan/dependencies/ || true
    ln -sf ${log4cplus}/lib/* build-linux/conan/dependencies/ || true
    ln -sf ${xxHash}/lib/* build-linux/conan/dependencies/ || true
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DBIN_INSTALL_DIR=${placeholder "out"}/bin"
    "-DBUILD_UNIT_TESTS=OFF"
    "-DKDRIVE_THEME_DIR=${src}/infomaniak"
    "-DCONAN_DEP_DIR=build-linux/conan/dependencies"
    "-DQT_FEATURE_neon=OFF"
    "-DKDRIVE_DEBUG=0"
    "-Dlog4cplus_INCLUDE_DIR=${log4cplus}/include"
    "-Dlog4cplus_LIBRARY=${log4cplus}/lib/liblog4cplusU.so"
    "-DCMAKE_PREFIX_PATH=${lib.concatStringsSep ";" [
      log4cplus
      xxHash
      poco
      sentry-native
      libzip
    ]}"
  ];

  # Build en parallèle
  enableParallelBuilding = true;

  # Éviter l'installation dans /kDrive
  preInstall = ''
    # Patcher cmake_install.cmake pour éviter d'installer dans /kDrive
    find . -name cmake_install.cmake -exec sed -i 's|file(MAKE_DIRECTORY "/kDrive")|# &|g' {} +
    find . -name cmake_install.cmake -exec sed -i 's|"/kDrive"|"$ENV{out}/kDrive"|g' {} +
    # Ignorer uniquement les lignes file(INSTALL qui utilisent CRASHPAD_HANDLER_PROGRAM-NOTFOUND
    find . -name cmake_install.cmake -exec sed -i '/file(INSTALL.*CRASHPAD_HANDLER_PROGRAM-NOTFOUND/d' {} +
  '';

  # Installation personnalisée
  postInstall = ''
    # Copier le fichier d'exclusion de synchronisation
    cp ${src}/sync-exclude-linux.lst $out/bin/sync-exclude.lst

    # Créer les répertoires nécessaires
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/512x512/apps

    # Copier les fichiers desktop et icônes s'ils existent
    if [ -f $out/share/applications/kDrive_client.desktop ]; then
      sed -i "s|Exec=.*|Exec=$out/bin/kDrive|g" $out/share/applications/kDrive_client.desktop
    fi
  '';

  # Wrapper pour les chemins Qt et autres dépendances
  postFixup = ''
    wrapProgram $out/bin/kDrive \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}" \
      --prefix QML2_IMPORT_PATH : "${qt6.qtbase}/${qt6.qtbase.qtQmlPrefix}"
    
    # Wrapper pour le client si différent
    if [ -f $out/bin/kDrive_client ]; then
      wrapProgram $out/bin/kDrive_client \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
        --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${qt6.qtbase}/${qt6.qtbase.qtQmlPrefix}"
    fi
  '';

  meta = with lib; {
    description = "Infomaniak kDrive - Client de synchronisation desktop";
    homepage = "https://github.com/Infomaniak/desktop-kDrive";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "kDrive";
  };
}
