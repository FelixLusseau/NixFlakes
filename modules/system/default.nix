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
          appimage-run
          jmtpfs
        ];
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
          };
        };
        users.extraGroups.docker.members = userNames;
        environment.systemPackages = with pkgs; [
          dive
        ];
      }
    )
    (mkIf cfg.virt.enable
      {
        programs.virt-manager.enable = true;
        users.groups.libvirtd.members = userNames;
        virtualisation.libvirtd.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
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
