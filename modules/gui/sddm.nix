{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "sddm-vivid-theme-dialog";
  version = "1.0";
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes
    cp -aR $src/Vivid\ SDDM\ Themes/Vivid-SDDM-6/ $out/share/sddm/themes/sddm-vivid-theme-dialog
  '';
  src = fetchFromGitHub {
    owner = "L4ki";
    repo = "Vivid-Plasma-Themes";
    rev = "b16f14ce43066abfcbe8e55dea9718d5070e0f66";
    sha256 = "070zb4ybki7509ifn6bpdp805yry9m2yi3mf99g8igs8cblyd6la";
  };
})
