{ config, pkgs, lib, ... }:

let cfg = config.flcraft.gui;
in
with lib;
with types;

{
  imports =
  [
    ./packages.nix
    ./conky
    ./home-manager
  ];

  config = mkMerge [
    (mkIf cfg.enable
      {
        # Configure keymap in X11
        services.xserver.xkb = {
          layout = "fr";
          variant = "";
        };

        # Configure console keymap
        console.keyMap = "fr";

        # Touchpad scrolling
        services.libinput.touchpad.naturalScrolling = true;

        # Fonts
        fonts = {
          fonts = with pkgs; [ fira-code fira-code-symbols noto-fonts-emoji ];
          fontconfig.defaultFonts.monospace = [ "Fira Code" ];
          fontconfig.defaultFonts.emoji = [ "Noto Color Emoji" ];
        };

        # Enable sound with pipewire.
        hardware.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      }
    )
  ];
}
