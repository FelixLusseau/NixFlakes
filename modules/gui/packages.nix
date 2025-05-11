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
            font-manager
            kdePackages.kate
            kdePackages.kalk
            spotify
            (callPackage ./deezer.nix {})
            nextcloud-client
            seafile-client
            conky
            vlc
            mpv
            keepassxc
            brave
            xournalpp
            # kmymoney
            meld
            (callPackage ./sddm.nix {})
            (callPackage ./home-manager/theme/vivid.nix {})
            (callPackage ./home-manager/theme/vivid-dark-icons.nix {})
            (callPackage ./home-manager/theme/gently.nix {})
            gparted
            ntfs3g
            resources
        ];
        programs.firefox.enable = true;

        # Enable the X11 windowing system.
        # You can disable this if you're only using the Wayland session.
        # services.xserver.enable = true;
        services.displayManager.sddm.wayland.enable = true;
        services.displayManager.sddm.autoNumlock = true;

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
            nodejs_24
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
          kdePackages.kdenlive
          shotwell
        ];
      }
    )
    (mkIf cfg.pkgs.gaming.enable
      {
        environment.systemPackages = with pkgs; [
          # minecraft # Broken 25/01/2025
        ];
      }
    )
  ];
}
