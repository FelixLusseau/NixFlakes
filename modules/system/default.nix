{config, lib, pkgs, ...}:
let
  cfg = config.flcraft.system;
in
with lib;
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
          nix-index # Find which package contains a bin / a lib
          appimage-run
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
        users.extraGroups.docker.members = [ "felix" ];
        environment.systemPackages = with pkgs; [
          dive
        ];
      }
    )
    (mkIf cfg.virt.enable
      {
        programs.virt-manager.enable = true;
        users.groups.libvirtd.members = [ "felix" ];
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
          ];
      }
    )
  ];
}
