{ config, pkgs, lib, ... }:
with lib;
with types; 
let
    mapUsers = f: attrsets.mapAttrs f config.flcraft.users;
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = mapUsers ( name: cfg: if name != "root" then {
      isNormalUser = true;
      description = cfg.description;
      extraGroups = [ "networkmanager" "wheel" ];
      useDefaultShell = true;
  } else {});
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = mapUsers ( name: cfg: {
      home.stateVersion = "24.05";

      # Home Manager needs a bit of information about you and the
      # paths it should manage.
      home = {
        username = name;
      };

      home.packages = with pkgs; [
        nixpkgs-fmt # nix formatting tool
        nix-prefetch-git

        ani-cli
        spicetify-cli
        
        wl-clipboard
        wf-recorder
    
        ueberzug
        # archives
        zip
        unzip

        brightnessctl # control screen brightness

        xclip
        
        # libreoffice
        dnsutils
      ];

      xsession.numlock.enable = true; # -> I'm on Wayland...

      programs = {
        # Let Home Manager install and manage itself.
        home-manager.enable = true;

        neovim = {
          enable = true;
          extraConfig = ''
            set number relativenumber
          '';
        };

        plasma = {
          enable = true;
          overrideConfig = true;

          workspace = {
            theme = "Vivid-Dark-Plasma"; #"breeze-dark";
            colorScheme ="VividCyanDarkColorscheme"; #"breeze-dark";
            # lookAndFeel = "Vivid-Dark-Global-6"; #"org.kde.breezedark.desktop"
            iconTheme = "Vivid-Dark-Icons";
            windowDecorations = {
              theme = "__aurorae__svg__Gently-Blur-Dark-Aurorae-6";
              library = "org.kde.kwin.aurorae";
            };
            splashScreen = { 
              theme = "Vivid-Splash-6";
            };
            wallpaper = "/run/current-system/sw/share/plasma/wallpapers/Vivid\ Wallpapers/Vivid-Line\ Wallpaper\ With\ Plasma\ Logo.png";
          };

          # startup = {
          #   desktopScript = {
          #     conky = {
          #       text = ''
          #         cd /run/current-system/sw/share/conky/themes/auzia-conky ; conky -c conkyrc
          #       '';
          #     };
          #   };
          # };

          input = {
            touchpads = [
              {
                name = "SYNA7DAB:01 06CB:CD40 Touchpad";
                naturalScroll = true;
                vendorId = "06cb";
                productId = "cd40";
              }
            ];
          };

          panels = [
            # Windows-like panel at the top
            {
              location = "top";
              screen = "all";
              floating = true;
              widgets = [
                "org.kde.plasma.kickoff"
                "org.kde.plasma.pager"
                # "org.kde.plasma.icontasks"
                "org.kde.plasma.panelspacer"
                "org.kde.plasma.marginsseparator"
                "org.kde.plasma.systemtray"
                "org.kde.plasma.digitalclock"
                "org.kde.plasma.showdesktop"
              ];
            }
            {
              location = "bottom";
              screen = "all";
              floating = true;
              lengthMode = "fit";
              height = 48;
              widgets = [
                {
                  iconTasks = {
                    launchers = [
                      "applications:org.kde.dolphin.desktop"
                      "file://${pkgs.firefox}/share/applications/firefox.desktop"
                      "file://${pkgs.google-chrome}/share/applications/google-chrome.desktop"
                      "file://${pkgs.systemsettings}/share/applications/systemsettings.desktop"
                      "file://${pkgs.spotify}/share/applications/spotify.desktop"
                      "applications:org.kde.plasma-systemmonitor.desktop"
                      "file://${pkgs.discord}/share/applications/discord.desktop"
                      "file://${pkgs.brave}/share/applications/brave-browser.desktop"
                      "file://${pkgs.vscode}/share/applications/code.desktop"
                      "file://${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop"
                      "file://${pkgs.signal-desktop}/share/applications/signal-desktop.desktop"
                      "file://${pkgs.element-desktop}/share/applications/element-desktop.desktop"
                    ];
                  };
                }
              ];
            }
          ];

          kscreenlocker = { 
            timeout = 15;
            appearance = {
              alwaysShowClock = true;
              showMediaControls = true;
            };
          };

          kwin = {
            nightLight = {
              enable = true;
              # mode = "times";
              # temperature = {
              #   day = 6500;
              #   night = 4500;
              # };
              # time = {
              #   evening = "21:00";
              #   morning = "07:00";
              # };
              mode = "location";
              location = { # Paris
                latitude = "48.862725";
                longitude = "2.287592";
              };
              transitionTime = 5;
            };
          };
          configFile = {
            kwinrc.Desktops.Number = {
              value = 9;
              # Forces kde to not change this value (even through the settings app).
              immutable = true;
            };
            kwinrc.Desktops.Rows = 3;
          };
        };


        firefox.enable = true;
        alacritty.enable = true;
        floorp.enable = false;

        git = (mkIf cfg.git.enable {
          enable = true;
          difftastic.enable = true;
          userName = cfg.git.userName;
          userEmail = cfg.git.userEmail;
        });
      };
    });
  };
}