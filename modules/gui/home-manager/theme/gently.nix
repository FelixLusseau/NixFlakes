{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "Gently-Blur-Dark-Aurorae";
  version = "1.0";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/aurorae/themes
    cp -aR $src/Gently\ Aurorae/Gently-Blur-Dark-Aurorae-6/ $out/share/aurorae/themes/
  '';
  src = fetchFromGitHub {
    owner = "L4ki";
    repo = "Gently";
    rev = "fee7cd048197e584d0e7c44fd65776a2ff861ef4";
    sha256 = "wow27jilRcaxU8277KfTY7N/WBNGS5AN3WGgPLh0Zzo=";
  };
}
