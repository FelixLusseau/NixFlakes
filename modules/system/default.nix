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
      }
    )
  ];
}