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
        rev = "740a1fe762f0658e6cc05b3c23da704c33773d83";
        sha256 = "07njlcpgdpn0jzr7pmss2789hvafy4myyyqy1j76gx8mh2ipqpxs";
    };
}
