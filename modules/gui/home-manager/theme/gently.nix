{ stdenv, fetchFromGitHub }:

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