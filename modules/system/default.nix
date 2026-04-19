{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.flcraft.system;
  userNames = builtins.attrNames (lib.filterAttrs (name: _: name != "root") config.flcraft.users);
  cortexPkgs = pkgs.callPackage ./cortex/default.nix {
    nodename = config.networking.hostName;
  };
in
{
  imports = [
    ./splash
  ];

  config = mkMerge [
    ({
      nix.settings.trusted-users = userNames;
      environment.systemPackages = with pkgs; [
        wireguard-tools
        pciutils
        usbutils
        ffmpeg
        sbctl
        # nix-index # Find which package contains a bin / a lib
        jmtpfs
        sshfs
        file # To display file types
        nixfmt
        tmux
      ];
      networking.networkmanager.plugins = with pkgs; [
        networkmanager-openvpn
      ];
      boot.tmp = {
        cleanOnBoot = true; # Clean /tmp on boot
        # useTmpfs = true; # Use tmpfs for /tmp
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
      };
      services.orca.enable = false;
      services.speechd.enable = false;
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
      services.printing.enable = true;
    })
    (mkIf cfg.hardware.fingerprint.enable {
      services.fprintd.enable = true;
      security.pam.services.swaylock = { };
      security.pam.services.swaylock.fprintAuth = true;
    })
    (mkIf cfg.network-tools.enable {
      environment.systemPackages = with pkgs; [
        nmap
        tcpdump
        ipcalc
        dig
        trippy
        traceroute
        snitch # Boosted ss
      ];
    })
    (mkIf cfg.ssh.enable {
      services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
          PasswordAuthentication = false;
          AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
          UseDns = true;
          X11Forwarding = false;
          PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        };
      };
    })
    (mkIf cfg.docker.enable {
      virtualisation.docker = {
        enable = true;
        daemon.settings = {
          # data-root = "/some-place/to-store-the-docker-data";
          daemonConfig = {
            ipv6 = true;
            "fixed-cidr-v6" = "fd00::/80";
          };
        };
      };
      users.extraGroups.docker.members = userNames;
      environment.systemPackages = with pkgs; [
        dive
        # (callPackage ./dcv.nix { })
        dcv
      ];
    })
    (mkIf cfg.virt.vm.enable {
      programs.virt-manager.enable = true;
      users.groups.libvirtd.members = userNames;
      virtualisation.libvirtd.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
      environment.systemPackages = with pkgs; [
        virtiofsd
      ];
    })
    (mkIf cfg.virt.lxc.enable {
      virtualisation.incus = {
        enable = true;
        preseed = {
          networks = [
            {
              config = {
                "ipv4.address" = "10.0.100.1/24";
                "ipv4.nat" = "true";
                "ipv6.address" = "fd00:100::1/64";
                "ipv6.nat" = "true";
              };
              name = "incusbr0";
              type = "bridge";
            }
          ];
          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  size = "35GiB";
                  type = "disk";
                };
              };
              name = "default";
            }
          ];
          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };
              driver = "dir";
              name = "default";
            }
          ];
        };
      };
      networking.nftables.enable = true;
      # networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
      #   53
      #   67
      # ];
      # networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
      #   53
      #   67
      # ];
      networking.firewall.trustedInterfaces = [ "incusbr0" ];

      users.extraGroups.incus-admin.members = userNames;

    })
    (mkIf cfg.kube.enable {
      environment.systemPackages = with pkgs; [
        kubecm
        kubectl
        kubecolor
        kubectx
        kube-bench
        kube-capacity
        stern
        (wrapHelm kubernetes-helm {
          plugins = with pkgs.kubernetes-helmPlugins; [
            #helm-secrets
            helm-diff
            helm-git
          ];
        })
        helmfile
        azure-cli
        terraform
        ansible
        busybox # contains envdir
      ];
    })
    (mkIf (cfg.kube.enable && config.flcraft.gui.enable) {
      environment.systemPackages = with pkgs; [
        # lens
        (callPackage ./freelens.nix { })
      ];
    })
    (mkIf cfg.blocky.enable {
      networking.nameservers = [
        "127.0.0.1"
        "::1"
      ];
      networking.resolvconf.enable = pkgs.lib.mkForce false;
      networking.dhcpcd.extraConfig = "nohook resolv.conf";
      networking.networkmanager.dns = "none";
      services.resolved.enable = false;
      services.blocky = {
        enable = true;
        settings = {
          ports.dns = 53; # Port for incoming DNS Queries.
          upstreams.groups.default = [
            "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
          ];
          # For initially solving DoH/DoT Requests when no system Resolver is available.
          bootstrapDns = {
            upstream = "https://one.one.one.one/dns-query";
            ips = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
          #Enable Blocking of certain domains.
          blocking = {
            denylists = {
              #Adblocking
              ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
            };
            #Configure what block categories are used
            clientGroupsBlock = {
              default = [ "ads" ];
            };
          };
        };
      };
    })
    (mkIf cfg.cortex.enable {
      # Install the package
      environment.systemPackages = [
        cortexPkgs.cortexAgent
        cortexPkgs.cortex-agent-fhs
      ];

      # Create configuration file
      environment.etc."panw/cortex.conf" = {
        text = ''
          --distribution-id ${cfg.cortex.distributionId}
          --distribution-server ${cfg.cortex.distributionServer}
        '';
        mode = "0600";
      };

      # Enable the service
      # systemd.services.cortex-agent = {
      #   description = "Palo Alto Networks Cortex XDR Agent(tm) daemon";
      #   after = [ "local-fs.target" "network.target" ];
      #   wantedBy = [ "multi-user.target" ];

      #   # preStart = ''
      #   #   # Setup runtime directories
      #   #   ${cortexPkgs.cortexAgent}/bin/cortex-setup-dirs

      #   #   # Ensure configuration exists
      #   #   if [ ! -f /etc/panw/cortex.conf ]; then
      #   #     echo "Error: Cortex configuration file not found at /etc/panw/cortex.conf"
      #   #     exit 1
      #   #   fi
      #   # '';

      #   serviceConfig = {
      #     Type = "forking";
      #     ExecStart = "${cortexPkgs.cortex-agent-fhs}/bin/cortex-agent-fhs";
      #     ExecStopPost="${cortexPkgs.cortex-agent-fhs}/opt/traps/km_utils/km_manage stop";
      #     Restart = "always";
      #     PIDFile = "/run/traps/pmd.pid";

      #     # Security settings
      #     NoNewPrivileges = false; # Cortex may need privileges
      #     PrivateTmp = false; # Cortex needs access to system tmp
      #     ProtectSystem = false; # Cortex needs system access
      #     ProtectHome = true; # Cortex may need home access
      #     # User = "traps"; # Run as the traps user
      #     # Group = "traps"; # Run as the traps group
      #   };
      # };

      # Required kernel modules and capabilities
      #boot.kernelModules = [ "tun" "tap" ];

      # Firewall exceptions if needed
      # networking.firewall.allowedTCPPorts = [ ];
      # networking.firewall.allowedUDPPorts = [ ];

      # Required system groups and users
      users.groups.traps = { };
      users.users.traps = {
        group = "traps";
        isSystemUser = true;
        home = "/opt/traps";
        shell = pkgs.bash;
      };
      users.groups.cortexuser = { };
      users.users.cortexuser = {
        group = "cortexuser";
        isSystemUser = true;
        shell = pkgs.bash;
      };

      # Runtime directories
      systemd.tmpfiles.rules = [
        "d /run/traps 0755 root root -"
        "d /var/log/traps 0755 root root -" # Sur le host ? N'est pas accessible dans le container
      ];
    })
  ];
}
