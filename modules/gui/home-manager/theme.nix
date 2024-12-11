{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
    pname = "Vivid-Dark-Plasma";
    version = "1.0";
    dontBuild = true;
    installPhase = ''
        mkdir -p $out/share/plasma/desktoptheme
        cp -aR $src/Vivid\ Plasma\ Themes/ $out/share/plasma/desktoptheme/Vivid-Dark-Plasma/
        mkdir -p $out/share/icons
        cp -aR $src/Vivid\ Icons\ Themes/ $out/share/icons/Vivid-Dark-Icons/
    '';
    src = fetchFromGitHub {
        owner = "L4ki";
        repo = "Vivid-Plasma-Themes";
        rev = "b16f14ce43066abfcbe8e55dea9718d5070e0f66";
        sha256 = "070zb4ybki7509ifn6bpdp805yry9m2yi3mf99g8igs8cblyd6la";
    };
}
