{ config, lib, pkgs, ... }:

let cfg = config.flcraft.gui;
in
with lib;
with types;
{
  config = mkMerge [
    (mkIf cfg.enable
      {
        environment.systemPackages = with pkgs; [
            google-chrome
            nautilus
            font-manager
            spotify
            nextcloud-client
            seafile-client
            gparted
            conky
            vlc
            keepassxc
            brave
            xournalpp
            wireguard-tools
            (callPackage ./sddm.nix {})
        ];
        programs.firefox.enable = true;

        # Enable the X11 windowing system.
        # You can disable this if you're only using the Wayland session.
        # services.xserver.enable = true;
        services.displayManager.sddm.wayland.enable = true;

        # Enable the KDE Plasma Desktop Environment.
        services.displayManager.sddm.enable = true;
        services.desktopManager.plasma6.enable = true;
        # Custom SDDM theme
        services.displayManager.sddm.theme = "sddm-vivid-theme-dialog";
      }
    )
    (mkIf cfg.pkgs.messages.enable
      {
        environment.systemPackages = with pkgs; [
            thunderbird
            element-desktop
            signal-desktop
            discord
        ];
      }
    )
    (mkIf cfg.pkgs.programming.enable
      {
        environment.systemPackages = with pkgs; [
            vscode
            bruno
            python3
        ];
      }
    )
    (mkIf cfg.pkgs.art.enable
      {
        environment.systemPackages = with pkgs; [
          krita
          gimp
        #   darktable
          inkscape
          kdenlive
        ];
      }
    )
  ];
}