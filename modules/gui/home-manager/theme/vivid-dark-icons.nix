{ stdenv }:

stdenv.mkDerivation rec {
    pname = "Vivid-Dark-Icons";
    version = "1.0";
    src = ./Vivid-Dark-Icons.tar.gz;
    dontBuild = true;
    installPhase = ''
        mkdir -p $out/share/icons
        tar -xzf $src -C $out/share/icons/Vivid-Dark-Icons/
    '';
}