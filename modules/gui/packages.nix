{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.flcraft.gui;
in
with lib;
with types;
{
  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        google-chrome
        font-manager
        kdePackages.kate
        kdePackages.kalk
        spotify
        # (callPackage ./deezer.nix { })
        deezer-desktop
        nextcloud-client
        (callPackage ./kdrive.nix { })
        conky
        vlc
        mpv
        keepassxc
        brave
        xournalpp
        kmymoney
        meld
        (callPackage ./sddm.nix { })
        (callPackage ./home-manager/theme/vivid.nix { })
        (callPackage ./home-manager/theme/vivid-dark-icons.nix { })
        (callPackage ./home-manager/theme/gently.nix { })
        gparted
        ntfs3g
        resources
      ];

      programs.kdeconnect.enable = true;

      services.displayManager.sddm = {
        # Enable the KDE Plasma Desktop Environment.
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        # Custom SDDM theme
        theme = "sddm-vivid-theme-dialog";
      };

      services.desktopManager.plasma6.enable = true;
    })
    (mkIf (cfg.enable && cfg.pkgs.messages.enable) {
      environment.systemPackages = with pkgs; [
        thunderbird
        element-desktop
        signal-desktop
        discord
      ];
    })
    (mkIf (cfg.enable && cfg.pkgs.programming.enable) {
      environment.systemPackages = with pkgs; [
        bruno
        python3
        nodejs_25
      ];
    })
    (mkIf (cfg.enable && cfg.pkgs.art.enable) {
      environment.systemPackages = with pkgs; [
        krita
        gimp3
        #   darktable
        inkscape
        # kdePackages.kdenlive
        shotwell
      ];
    })
    (mkIf (cfg.enable && cfg.pkgs.gaming.enable) {
      hardware.xone.enable = true; # Enable Xbox One controller support
      environment.systemPackages = with pkgs; [
        # minecraft # Broken 25/01/2025
        prismlauncher
        (callPackage ./rvgl.nix { })
        heroic
      ];
      programs.steam = {
        enable = true;
      };
    })
  ];
}
