{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, bash
, glibc
, zlib
, openssl
, systemd
, libselinux
, libsemanage
, procps
, coreutils
, util-linux
, iproute2
, iptables
, kmod
, nettools
, pciutils
, usbutils
, buildFHSEnv
}:

let
  cortexAgent = stdenv.mkDerivation rec {
    pname = "cortex-agent";
    version = "8.6.0.127790";

    src = ./cortex-agent-8.6.0.127790.tar.gz;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
    ];

    autoPatchelfIgnoreMissingDeps = [ "libsemanage.so.1" ];

    buildInputs = [
      bash
      glibc
      zlib
      openssl
      systemd
      libselinux
      libsemanage
    ];

    runtimeDependencies = [
      procps
      coreutils
      util-linux
      iproute2
      iptables
      kmod
      nettools
      pciutils
      usbutils
      systemd
    ];

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      runHook preUnpack
      tar -xzf $src
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      # Create directory structure
      mkdir -p $out/{bin,sbin,lib/systemd/system,etc/cortex,share/cortex}
      mkdir -p $out/opt/traps/{bin,lib,modules,etc,logs,tmp}

      # Copy ALL content from the archive to /opt/traps/
      cp -r . $out/opt/traps/

      # Remplace le binaire openssl par celui de Nixpkgs
      rm -f $out/opt/traps/bin/openssl

      # Install main executables
      install -m755 bin/pmd $out/opt/traps/bin/
      install -m755 bin/cytool $out/opt/traps/bin/
      install -m755 analyzerd/sandboxd $out/opt/traps/bin/ || true
      install -m755 analyzerd/spmd $out/opt/traps/bin/ || true

      # Create wrapper scripts for system binaries
      makeWrapper $out/opt/traps/bin/cytool $out/bin/cytool \
        --prefix PATH : ${lib.makeBinPath runtimeDependencies}

      # Create configuration directory
      mkdir -p $out/etc/panw

      runHook postInstall
    '';

    postFixup = ''
      # Fix permissions
      chmod +x $out/opt/traps/bin/*

  #     # Create runtime directories script
  #     cat > $out/bin/cortex-setup-dirs << EOF
  # #!/bin/bash
  # mkdir -p /var/run/traps
  # mkdir -p /var/log/traps
  # mkdir -p /tmp/traps
  # chown root:root /var/run/traps /var/log/traps /tmp/traps
  # chmod 755 /var/run/traps /var/log/traps /tmp/traps
  # EOF
  #     chmod +x $out/bin/cortex-setup-dirs
      patchShebangs $out
      ln -s ${openssl}/bin/openssl $out/opt/traps/bin/openssl
    '';

    meta = with lib; {
      description = "Palo Alto Networks Cortex XDR endpoint security agent";
      homepage = "https://www.paloaltonetworks.com/cortex/cortex-xdr";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
      maintainers = [ ];
    };
  };
  cortex-agent-fhs = buildFHSEnv {
    name = "cortex-agent-fhs";
    targetPkgs = pkgs: [
      cortexAgent
      bash
      glibc
      zlib
      openssl
      systemd
      libselinux
      libsemanage
      procps
      coreutils
      util-linux
      iproute2
      iptables
      kmod
      nettools
      pciutils
      usbutils
    ];
    runScript = ''
      #!/bin/bash
      set -euo pipefail

      export PATH="/bin:/sbin:$PATH"

      # Répertoire réel en lecture seule dans le Nix store
      readonly LOWER="${cortexAgent}/opt/traps"
      
      # Répertoires temporaires en lecture-écriture
      readonly UPPER="/tmp/cortex-agent-upper"
      readonly WORK="/tmp/cortex-agent-work"
      readonly MERGED="/opt/traps"

      mkdir -p "$UPPER" "$WORK" "$MERGED"

      # Monter l'overlayfs pour /opt/traps
      mount -t overlay overlay \
        -o lowerdir="$LOWER",upperdir="$UPPER",workdir="$WORK" \
        "$MERGED"

      # --- Overlayfs direct sur /var/log ---
      mkdir -p /tmp/cortex-agent-logs-upper /tmp/cortex-agent-logs-work
      mount -t overlay overlay \
        -o lowerdir=/var/log,upperdir=/tmp/cortex-agent-logs-upper,workdir=/tmp/cortex-agent-logs-work \
        /var/log

      mkdir -p /var/log/traps/coredumps/

      # Lancer l'agent depuis le merged FS ou ouvrir un shell
      ${cortexAgent}/opt/traps/bin/pmd
      # /bin/bash
    '';
    extraBuildCommands = ''
      mkdir -p $out/var/{log,cache/ldconfig}
      chmod 700 $out/var/{log,cache/ldconfig}
    '';
  };
in
{
  cortexAgent = cortexAgent;
  cortex-agent-fhs = cortex-agent-fhs;
}