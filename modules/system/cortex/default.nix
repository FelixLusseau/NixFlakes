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

      # Create systemd service file
      cat > $out/lib/systemd/system/cortex-agent.service << EOF
  [Unit]
  Description=Cortex XDR Agent
  After=network.target
  Wants=network.target

  [Service]
  Type=forking
  ExecStart=$out/opt/traps/bin/pmd
  ExecReload=/bin/kill -HUP \$MAINPID
  KillMode=process
  Restart=on-failure
  RestartSec=42s
  PIDFile=/var/run/traps/pmd.pid

  [Install]
  WantedBy=multi-user.target
  EOF

      # Create configuration directory
      mkdir -p $out/etc/panw

      runHook postInstall
    '';

    postFixup = ''
      # Fix permissions
      chmod +x $out/opt/traps/bin/*

      # Create runtime directories script
      cat > $out/bin/cortex-setup-dirs << EOF
  #!/bin/bash
  mkdir -p /var/run/traps
  mkdir -p /var/log/traps
  mkdir -p /tmp/traps
  chown root:root /var/run/traps /var/log/traps /tmp/traps
  chmod 755 /var/run/traps /var/log/traps /tmp/traps
  EOF
      chmod +x $out/bin/cortex-setup-dirs
      patchShebangs $out/bin
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
      set -euo pipefail

      # Répertoire réel en lecture seule dans le Nix store
      readonly LOWER="${cortexAgent}/opt/traps"
      
      # Répertoires temporaires en lecture-écriture
      readonly UPPER="/tmp/cortex-agent-upper"
      readonly WORK="/tmp/cortex-agent-work"
      readonly MERGED="/opt/traps"

      mkdir -p "$UPPER" "$WORK" "$MERGED"

      # Monter l'overlayfs
      mount -t overlay overlay \
        -o lowerdir="$LOWER",upperdir="$UPPER",workdir="$WORK" \
        "$MERGED"

      # Lancer l'agent depuis le merged FS
      ${cortexAgent}/opt/traps/bin/pmd
    '';
    extraBuildCommands = ''
      mkdir -p $out/var/cache/ldconfig
      chmod 700 $out/var/cache/ldconfig
      # mkdir -p $out/var/log/traps/coredumps/
      # mkdir -p $out/opt/traps/{persist,ipc,download/content,traps_sockets}
      # chmod 01755 $out/opt/traps/traps_sockets
    '';
  };
in
{
  cortexAgent = cortexAgent;
  cortex-agent-fhs = cortex-agent-fhs;
}