{
  cores-nb,
  wifi-int-name,
  pkgs ? import <nixpkgs> {},
  theme ? "auzia-conky",
  fetchFromGitHub,
}:

pkgs.stdenv.mkDerivation {
  pname = "conky-theme";
  version = "0.1.1";

  src = fetchFromGitHub {
        owner = "SZinedine";
        repo = "auzia-conky";
        rev = "a2dca8a758b4487a2eaeaed9a76b616f1a210ea5"; # "07753f150684f2b68569d6e48697c978c1349ded";
        sha256 = "1xvzvjqvy2bfk8nsz8zjdqshrb91kxnfczbvc70fi10l2m6dabps"; # "1gp1617ap0dg6f4kmf2s4ycm207nbwslb8qg4a1v9305cj31v3kx";
    };

  buildInputs = [
  ];

  unpackPhase = ''
  '';

  configurePhase = ''
    mkdir -p $out/share/conky/themes/${theme}
  '';

  buildPhase = ''
  '';

  # Currently not multi-theme enabled
  installPhase = ''
    cp -r . $out/share/conky/themes/${theme}
    sed -i 's/middle_middle/top_right/g' $out/share/conky/themes/${theme}/conkyrc
    sed -i 's/cpu_cores = 4/cpu_cores = ${cores-nb}/g' $out/share/conky/themes/${theme}/settings.lua
    sed -i 's/net_interface = "wlan0"/net_interface = "${wifi-int-name}"/g' $out/share/conky/themes/${theme}/settings.lua
    sed -i 's/use_public_ip = false/use_public_ip = true/g' $out/share/conky/themes/${theme}/settings.lua
  '';
    # sed -i 's/startup_delay = 5/startup_delay = 15/g' $out/share/conky/themes/${theme}/settings.lua
}
