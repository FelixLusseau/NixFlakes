{
  cores-nb,
  wifi-int-name,
  pkgs ? import <nixpkgs> { },
  theme ? "auzia-conky",
  fetchFromGitHub,
}:

pkgs.stdenv.mkDerivation {
  pname = "conky-theme";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "SZinedine";
    repo = "auzia-conky";
    rev = "07753f150684f2b68569d6e48697c978c1349ded";
    sha256 = "1gp1617ap0dg6f4kmf2s4ycm207nbwslb8qg4a1v9305cj31v3kx";
  };

  buildInputs = [ ];

  nativeBuildInputs = [
    pkgs.lm_sensors
  ];

  unpackPhase = "";

  configurePhase = ''
    mkdir -p $out/share/conky/themes/${theme}
  '';

  buildPhase = "";

  installPhase = ''
    cp -r . $out/share/conky/themes/${theme}

    substituteInPlace $out/share/conky/themes/${theme}/conkyrc \
      --replace-warn "middle_middle" "middle_right"

    substituteInPlace $out/share/conky/themes/${theme}/settings.lua \
      --replace-warn "cpu_cores = 4" "cpu_cores = ${cores-nb}" \
      --replace-warn 'net_interface = "wlan0"' 'net_interface = "${wifi-int-name}"' \
      --replace-warn "use_public_ip = false" "use_public_ip = true"

    substituteInPlace $out/share/conky/themes/${theme}/start.lua \
      --replace-warn \
        'get_public_ip == nil or (updates()%public_ip_refresh_rate) == 0' \
        'get_public_ip() == nil or (tonumber(updates()) % public_ip_refresh_rate) == 0' \
      --replace-warn \
        '"Public IP:      " .. get_public_ip()' \
        '"Public IP:      " .. (get_public_ip() or "No Address")'

    # Auzia utilise encore l'ancienne API Cairo/Xlib.
    # Conky 1.25.x + Wayland doit utiliser conky_surface().
    sed -i \
      '/local cs = cairo_xlib_surface_create/,/conky_window.height)/c\
    local cs = conky_surface()' \
      $out/share/conky/themes/${theme}/start.lua

    # conky_surface() appartient à Conky : ne pas détruire la surface.
    sed -i \
      '/cairo_surface_destroy(cs)/d' \
      $out/share/conky/themes/${theme}/start.lua

    # abstract.lua importe cairo_xlib dans le dépôt d'origine,
    # mais il n'est plus nécessaire avec conky_surface().
    sed -i \
      '/require("cairo_xlib")/d' \
      $out/share/conky/themes/${theme}/abstract.lua

    sed -i \
      "\|function cpu_temperature_sensors()|,/^end$/c\\
    function cpu_temperature_sensors()\\
        local file = io.popen(\"${pkgs.lm_sensors}/bin/sensors 2> /dev/null\")\\
    \\
        if not file then\\
            io.stderr:write(\"Error while executing 'sensors'. Defaulting to cpu_temperature()\\\\n\")\\
            return cpu_temperature()\\
        end\\
    \\
        local result\\
    \\
        for line in file:lines() do\\
            result = line:match(\"^Tctl:%s+([%+%-]?%d+%.?%d*)\")\\
                or line:match(\"^Tdie:%s+([%+%-]?%d+%.?%d*)\")\\
                or line:match(\"^Package id 0:%s+([%+%-]?%d+%.?%d*)\")\\
                or line:match(\"^CPU Temp:%s+([%+%-]?%d+%.?%d*)\")\\
    \\
            if result then\\
                result = result:gsub(\"^%+\", \"\")\\
                break\\
            end\\
        end\\
    \\
        file:close()\\
    \\
        if tonumber(result) == nil then\\
            io.stderr:write(\"Error. Invalid CPU temperature from 'sensors'. Defaulting to cpu_temperature()\\\\n\")\\
            return cpu_temperature()\\
        end\\
    \\
        return result\\
    end" \
      $out/share/conky/themes/${theme}/abstract.lua
  '';
}
