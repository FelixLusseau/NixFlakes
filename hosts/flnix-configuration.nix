{ config, pkgs, ... }:

{
  flcraft = {
    users = {
      felix = {
        description = "Félix";
        git = {
          enable = true;
          userName = "Me";
          userEmail = "me@mail.com";
        };
      };
    };
    shell = {
      zsh = {
        enable = true;
      };
    };
    system = {
      ssh = {
        enable = true;
      };
    };
    gui = {
      enable = true;
      pkgs = {
        messages.enable = true;
        programming.enable = true;
        art.enable = true;
      };
    };
  };

  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = true;
      gfxmodeEfi = "1920x1080";
    };
    timeout = 2;
  };

  # Plymouth splash screen
  boot.plymouth = {
    enable = true;
    theme = "plymouth-felix";
    themePackages = [
      pkgs.splash-boot
    ];
    logo = ../modules/system/splash/Chat-licorne.png;
  };

  networking.hostName = "flnix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  programs.nix-ld.enable = true; # to run non-nix executables

  # VM screen resize
  services.spice-vdagentd.enable = true;
  services.qemuGuest.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nux command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    curl
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
