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
      virt.enable = mkEnableOption "Activate Virtualisation tools";
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
