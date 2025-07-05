{ lib, ... }:

with lib;
with types;
let
  userModule = { name, config, ... }:
  {
    options = {
      description = mkOption {
        type = types.str;
        default = "";
      };
      git = {
        enable = mkEnableOption "Activate git";
        userName = mkOption {
          type = types.str;
          default = name;
        };
        userEmail = mkOption {
          type = types.str;
          default = "";
        };
      };
    };
  };
in
{
  imports = [
    ./shell
    ./system
    ./gui
  ];

  options.flcraft = {
    users  = mkOption {
      type = attrsOf ( submodule userModule );
    };
    shell = {
      zsh = {
        enable = mkEnableOption "Activate ZSH as default shell";
      };
    };
    system = {
      docker.enable = mkEnableOption "Activate Docker";
      virt.vm.enable = mkEnableOption "Activate VM Virtualisation tools";
      virt.lxd.enable = mkEnableOption "Activate LXD Virtualisation tools";
      kube.enable = mkEnableOption "Activate Kubernetes tools";
      ssh.enable = mkEnableOption "Activate SSH server";
      network-tools.enable = mkEnableOption "Install network tools";
      hardware = {
        cores-nb = mkOption {
          type = types.str;
          default = "8";
        };
        wifi-int-name = mkOption {
          type = types.str;
        };
        fingerprint.enable = mkEnableOption "Activate fingerprint";
      };
      blocky.enable = mkEnableOption "Activate Blocky Ads Blocker"; # A reboot is required to apply the changes
      cortex = {
        enable = mkEnableOption "Cortex XDR Agent";

        configFile = mkOption {
          type = types.path;
          default = /etc/panw/cortex.conf;
          description = "Path to the Cortex XDR configuration file";
        };

        distributionId = mkOption {
          type = types.str;
          example = "033c89d0a73e4f28b8f226441fcc17c6";
          description = "Distribution ID for Cortex XDR";
        };

        distributionServer = mkOption {
          type = types.str;
          default = "https://distributions.traps.paloaltonetworks.com/";
          description = "Distribution server URL for Cortex XDR";
        };
      };
    };
    gui = {
      enable = mkEnableOption "Activate GUI";
      pkgs = {
        messages.enable = mkEnableOption "Activate messages apps";
        programming.enable = mkEnableOption "Activate programming";
        art.enable = mkEnableOption "Activate image and video editing";
        gaming.enable = mkEnableOption "Activate games";
      };
    };
  };

  config = {
    time.timeZone = "Europe/Paris";

    # Internationalisation properties.
    i18n = {
      defaultLocale = "fr_FR.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };
    };
  };
}
