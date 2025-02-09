{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
    pname = "Vivid-Dark-Icons";
    version = "1.0";
    src = fetchurl {
        url = "file:///home/felix/Nix/NixFlakes/modules/gui/home-manager/theme/Vivid-Dark-Icons.tar.gz";
        sha256 = "7b21e8805e1f0b632c1197208ff84e791bc47a54d1a046fbcfcf84393a971024";
    };
    dontBuild = true;
    installPhase = ''
        mkdir -p $out/share/icons
        cp -aR $src/ $out/share/icons/Vivid-Dark-Icons/
    '';
}