{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  poco,
  cppunit,
  sentry-native,
  libzip,
  openssl,
  zlib,
  log4cplus,
  xxHash,
  sqlite,
  libsecret,
  libGL,
  mesa,
  freeglut,
  glib,
  makeWrapper,
  nss,
  xorg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kdrive";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "Infomaniak";
    repo = "desktop-kDrive";
    tag = "${finalAttrs.version}";
    sha256 = "sha256-7PVf04B8wqBRMkNl5UJb9Ht8LBNviqzrdlUjccLyN/Y=";
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
        # Create a minimal FindLog4cplus.cmake module
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
        
        # Add the module path
        substituteInPlace CMakeLists.txt \
          --replace-fail 'project(client)' \
                         'list(APPEND CMAKE_MODULE_PATH "''${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
    project(client)'
        
        # Patch library copying to use Nix paths
        substituteInPlace CMakeLists.txt \
          --replace-fail 'get_library_dirs("log4cplus" "log4cplus")' \
                         'set(_log4cplus_LIB_DIRS "${log4cplus}/lib")' \
          --replace-fail 'get_library_dirs("OpenSSL" "openssl")' \
                         'set(_OpenSSL_LIB_DIRS "${openssl.out}/lib")' \
          --replace-fail 'get_library_dirs("xxHash" "xxhash")' \
                         'set(_xxHash_LIB_DIRS "${xxHash}/lib")'
        
        # Replace variable paths with actual values using correct filenames (use Unicode version)
        substituteInPlace CMakeLists.txt \
          --replace-fail '"''${_log4cplus_LIB_DIRS}/liblog4cplus.so"' '"${log4cplus}/lib/liblog4cplusU.so"' \
          --replace-fail '"''${_log4cplus_LIB_DIRS}/liblog4cplus.so.9"' '"${log4cplus}/lib/liblog4cplusU-2.1.so.9"' \
          --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so"' '"${xxHash}/lib/libxxhash.so"' \
          --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so.0"' '"${xxHash}/lib/libxxhash.so.0"' \
          --replace-fail '"''${_xxHash_LIB_DIRS}/libxxhash.so.0.8.2"' '"${xxHash}/lib/libxxhash.so.0.8.3"'
        
        # Patch CMakeLists to add RelWithDebInfo configuration for libzip
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

  # Create an empty dependency directory for Conan
  preConfigure = ''
    export HOME=$TMPDIR
    mkdir -p build-linux/conan/dependencies

    # Create symbolic links to Nix dependencies
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
    "-DKDRIVE_THEME_DIR=${finalAttrs.src}/infomaniak"
    "-DCONAN_DEP_DIR=build-linux/conan/dependencies"
    "-DQT_FEATURE_neon=OFF"
    "-DKDRIVE_DEBUG=0"
    "-Dlog4cplus_INCLUDE_DIR=${log4cplus}/include"
    "-Dlog4cplus_LIBRARY=${log4cplus}/lib/liblog4cplusU.so"
    "-DCMAKE_CXX_FLAGS=-Wno-error=uninitialized" # Suppress uninitialized errors on v3.8.1
    "-DCMAKE_PREFIX_PATH=${
      lib.concatStringsSep ";" [
        log4cplus
        xxHash
        poco
        sentry-native
        libzip
      ]
    }"
  ];

  # Parallel build
  enableParallelBuilding = true;

  # Avoid installing to /kDrive
  preInstall = ''
    # Patch cmake_install.cmake to avoid installing to /kDrive
    find . -name cmake_install.cmake -exec sed -i 's|file(MAKE_DIRECTORY "/kDrive")|# &|g' {} +
    find . -name cmake_install.cmake -exec sed -i 's|"/kDrive"|"$ENV{out}/kDrive"|g' {} +
    # Only ignore file(INSTALL lines using CRASHPAD_HANDLER_PROGRAM-NOTFOUND
    find . -name cmake_install.cmake -exec sed -i '/file(INSTALL.*CRASHPAD_HANDLER_PROGRAM-NOTFOUND/d' {} +
  '';

  # Custom installation
  postInstall = ''
    # Copy the sync exclusion file
    cp ${finalAttrs.src}/sync-exclude-linux.lst $out/bin/sync-exclude.lst

    # Create necessary directories
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/512x512/apps

    # Copy desktop and icon files if they exist
    if [ -f $out/share/applications/kDrive_client.desktop ]; then
      sed -i "s|Exec=.*|Exec=$out/bin/kDrive|g" $out/share/applications/kDrive_client.desktop
    fi
  '';

  # Wrapper for Qt paths and other dependencies
  postFixup = ''
    wrapProgram $out/bin/kDrive \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}" \
      --prefix QML2_IMPORT_PATH : "${qt6.qtbase}/${qt6.qtbase.qtQmlPrefix}"

    # Wrapper for the client if different
    if [ -f $out/bin/kDrive_client ]; then
      wrapProgram $out/bin/kDrive_client \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
        --prefix QT_PLUGIN_PATH : "${qt6.qtbase}/${qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${qt6.qtbase}/${qt6.qtbase.qtQmlPrefix}"
    fi
  '';

  meta = {
    description = "Infomaniak kDrive - Desktop synchronization client";
    homepage = "https://github.com/Infomaniak/desktop-kDrive";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ FelixLusseau ];
    platforms = lib.platforms.linux;
    mainProgram = "kDrive";
  };
})
