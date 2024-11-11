{
  pkgs ? import <nixpkgs> {},
  theme ? "plymouth-felix",
  logo ? ./nixos.png,
}:
pkgs.stdenv.mkDerivation {
  pname = "splash-boot";
  version = "0.2.0";

  src = ./src;

  buildInputs = [
  ];

  unpackPhase = ''
  '';

  configurePhase = ''
    mkdir -p $out/share/plymouth/themes/${theme}
  '';

  buildPhase = ''
  '';

  # Currently not multi-theme enabled
  installPhase = ''
    cd ${theme}
    cp -r . ${theme}.script ${theme}.plymouth $out/share/plymouth/themes/${theme}
    cp ${logo} $out/share/plymouth/themes/${theme}/logo.png
    sed -i "s@\/usr\/@$out\/@" $out/share/plymouth/themes/${theme}/${theme}.plymouth
  '';
}
