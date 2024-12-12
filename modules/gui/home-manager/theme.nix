{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
    pname = "Vivid-Dark-Plasma";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
        mkdir -p $out/share/plasma/desktoptheme
        cp -aR $src/Vivid\ Plasma\ Themes/ $out/share/plasma/desktoptheme/Vivid-Dark-Plasma/
        mkdir -p $out/share/icons
        cp -aR $src/Vivid\ Icons\ Themes/Vivid-Dark-Icons/ $out/share/icons/Vivid-Dark-Icons/
        mkdir -p $out/share/plasma/wallpapers
        cp -aR $src/Vivid\ Wallpapers/ $out/share/plasma/wallpapers/
        mkdir -p $out/share/plasma/look-and-feel
        cp -aR $src/Vivid\ Splashscreen/* $out/share/plasma/look-and-feel/
        mkdir -p $out/share/color-schemes
        cp -aR $src/Vivid\ Color\ Schemes/* $out/share/color-schemes/
    '';
    src = fetchFromGitHub {
        owner = "L4ki";
        repo = "Vivid-Plasma-Themes";
        rev = "b16f14ce43066abfcbe8e55dea9718d5070e0f66";
        sha256 = "070zb4ybki7509ifn6bpdp805yry9m2yi3mf99g8igs8cblyd6la";
    };
}

stdenv.mkDerivation rec {
    pname = "Gently-Blur-Dark-Aurorae";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
        mkdir -p $out/share/kwin/decorations
        cp -aR $src/Gently\ Aurorae/ $out/share/kwin/decorations/
    '';
    src = fetchFromGitHub {
        owner = "L4ki";
        repo = "Gently";
        rev = "fee7cd048197e584d0e7c44fd65776a2ff861ef4";
        sha256 = "070zb4ybki7509ifn6bpdp805yry9m2yi3mf99g8igs8cblyd6la";
    };
}
