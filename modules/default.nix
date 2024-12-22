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
      # vim.enable    = mkEnableOption "Activate Vim advenced config";
      # nixvim.enable = mkEnableOption "Activate NeoVim advenced config";
      # tmux.enable   = mkEnableOption "Activate tmux advenced config";
      zsh = {
        enable = mkEnableOption "Activate ZSH as default shell";
      };
    };
    system = {
      ssh.enable = mkEnableOption "Activate SSH server";
      hardware = {
        cores-nb = mkOption {
          type = types.str;
          default = "8";
        };
        wifi-int-name = mkOption {
          type = types.str;
        };
      };
    };
    gui = {
      enable = mkEnableOption "Activate GUI";
      pkgs = {
        messages.enable = mkEnableOption "Activate messages apps";
        programming.enable = mkEnableOption "Activate programming";
        art.enable = mkEnableOption "Activate image and video editing";
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
