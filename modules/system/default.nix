{config, lib, pkgs, ...}:
with lib;
let
  cfg = config.flcraft.system;
  userNames = builtins.attrNames (lib.filterAttrs (name: _: name != "root") config.flcraft.users);
in
{
  imports =
  [
    ./splash
  ];

  config = mkMerge [
    (
      {
        environment.systemPackages = with pkgs; [
          wireguard-tools
          pciutils
          usbutils
          ffmpeg
          sbctl
          # nix-index # Find which package contains a bin / a lib
          jmtpfs
          sshfs
        ];
        boot.tmp = {
          cleanOnBoot = true; # Clean /tmp on boot
#          useTmpfs = true; # Use tmpfs for /tmp
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
      }
    )
    (mkIf cfg.hardware.fingerprint.enable
      {
        services.fprintd.enable = true;
        security.pam.services.swaylock = {};
        security.pam.services.swaylock.fprintAuth = true;
      }
    )
    (mkIf cfg.network-tools.enable
      {
        environment.systemPackages = with pkgs; [
          nmap
          tcpdump
          ipcalc
          dig
          trippy
          traceroute
        ];
      }
    )
    (mkIf cfg.ssh.enable
      {
        services.openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = true;
            AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
            UseDns = true;
            X11Forwarding = false;
            PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
          };
        };
      }
    )
    (mkIf cfg.docker.enable
      {
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
        ];
      }
    )
    (mkIf cfg.virt.vm.enable
      {
        programs.virt-manager.enable = true;
        users.groups.libvirtd.members = userNames;
        virtualisation.libvirtd.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
      }
    )
    (mkIf cfg.virt.lxd.enable
      {
        # Enable LXD.
        virtualisation.lxd = {
          enable = true;

          # This turns on a few sysctl settings that the LXD documentation recommends
          # for running in production.
          recommendedSysctlSettings = true;
        };

        # This enables lxcfs, which is a FUSE fs that sets up some things so that
        # things like /proc and cgroups work better in lxd containers.
        # See https://linuxcontainers.org/lxcfs/introduction/ for more info.
        #
        # Also note that the lxcfs NixOS option says that in order to make use of
        # lxcfs in the container, you need to include the following NixOS setting
        # in the NixOS container guest configuration:
        #
        # virtualisation.lxc.defaultConfig = "lxc.include = ''${pkgs.lxcfs}/share/lxc/config/common.conf.d/00-lxcfs.conf";
        virtualisation.lxc.lxcfs.enable = true;

        # This sets up a bridge called "mylxdbr0".  This is used to provide NAT'd
        # internet to the guest.  This bridge is manipulated directly by lxd, so we
        # don't need to specify any bridged interfaces here.
        networking.bridges = { mylxdbr0.interfaces = []; };

        # Add an IP address to the bridge interface.
        networking.localCommands = ''
          ip address add 192.168.92.1/24 dev mylxdbr0
        '';

        # Firewall commands allowing traffic to go in and out of the bridge interface
        # (and to the guest LXD instance).  Also sets up the actual NAT masquerade rule.
        networking.firewall.extraCommands = ''
          iptables -A INPUT -i mylxdbr0 -m comment --comment "my rule for LXD network mylxdbr0" -j ACCEPT

          # These three technically aren't needed, since by default the FORWARD and
          # OUTPUT firewalls accept everything everything, but lets keep them in just
          # in case.
          iptables -A FORWARD -o mylxdbr0 -m comment --comment "my rule for LXD network mylxdbr0" -j ACCEPT
          iptables -A FORWARD -i mylxdbr0 -m comment --comment "my rule for LXD network mylxdbr0" -j ACCEPT
          iptables -A OUTPUT -o mylxdbr0 -m comment --comment "my rule for LXD network mylxdbr0" -j ACCEPT

          iptables -t nat -A POSTROUTING -s 192.168.92.0/24 ! -d 192.168.92.0/24 -m comment --comment "my rule for LXD network mylxdbr0" -j MASQUERADE
        '';

        # ip forwarding is needed for NAT'ing to work.
        boot.kernel.sysctl = {
          "net.ipv4.conf.all.forwarding" = true;
          "net.ipv4.conf.default.forwarding" = true;
        };

        # kernel module for forwarding to work
        boot.kernelModules = [ "nf_nat_ftp" ];

        users.extraGroups.lxd.members = userNames;

        environment.etc."lxd/preseed.yaml".text = ''
          config:
            images.auto_update_interval: "0"
          # networks: {}
          storage_pools:
          - config:
              source: /var/lib/lxd/storage-pools/default
            description: ""
            name: default
            driver: dir
          profiles:
          - config: {}
            description: Default LXD profile
            devices:
              root:
                path: /
                pool: default
                type: disk
            name: default
          projects:
          - config:
              features.images: "true"
              features.networks: "true"
              features.profiles: "true"
              features.storage.volumes: "true"
            description: Default LXD project
            name: default
        '';

        systemd.services.lxd-preseed = {
          description = "LXD initialization with preseed YAML";
          wantedBy = [ "multi-user.target" ];
          requires = [ "lxd.socket" ];
          serviceConfig = {
            ExecStart = "${pkgs.lxd}/bin/lxd init --preseed < /etc/lxd/preseed.yaml";
            Type = "oneshot";
          };
        };
      }
    )
    (mkIf cfg.kube.enable 
      {
        environment.systemPackages = with pkgs; [
            kubecm
            kubectl
            kubecolor
            kubectx
            kube-bench
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
            lens
            busybox # contains envdir
          ];
      }
    )
    (mkIf cfg.blocky.enable 
      {
        networking.nameservers = [ "127.0.0.1" "::1" ];
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
              ips = [ "1.1.1.1" "1.0.0.1" ];
            };
            #Enable Blocking of certain domains.
            blocking = {
              denylists = {
                #Adblocking
                ads = ["https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"];
              };
              #Configure what block categories are used
              clientGroupsBlock = {
                default = [ "ads" ];
              };
            };
          };
        };
      }
    )
  ];
}
