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
      extraGroups = [ "networkmanager" "wheel" "disk" ];
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
        
        wl-clipboard
        wf-recorder
    
        # archives
        zip
        unzip

        brightnessctl # control screen brightness

        xclip
        
        # libreoffice
        dnsutils
      ];

      # xsession.numlock.enable = true; # -> I'm on Wayland...

      xdg.configFile."autostart/conky.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Conky
        Exec=bash -c "cd /run/current-system/sw/share/conky/themes/auzia-conky && conky -c conkyrc"
        X-KDE-autostart-after=panel
        X-KDE-autostart-enabled=true
      '';

      xdg.configFile."autostart/seafile.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Exec=seafile-applet
      Hidden=false
      NoDisplay=false
      X-GNOME-Autostart-enabled=true
      Name[fr_FR]=Seafile
      Name=Seafile
      Comment[fr_FR]=Seafile desktop sync client
      Comment=Seafile desktop sync client
      '';

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
            theme = "Vivid-Dark-Plasma"; 
            colorScheme ="VividCyanDarkColorscheme"; 
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
                      "file://${pkgs.thunderbird}/share/applications/thunderbird.desktop"
                      "file://${pkgs.kdePackages.systemsettings}/share/applications/systemsettings.desktop"
                      "file://${pkgs.spotify}/share/applications/spotify.desktop"
                      "applications:deezer.desktop"
                      "applications:org.kde.plasma-systemmonitor.desktop"
                      "file://${pkgs.discord}/share/applications/discord.desktop"
                      "file://${pkgs.brave}/share/applications/brave-browser.desktop"
                      "file://${pkgs.vscode}/share/applications/code.desktop"
                      "file://${pkgs.keepassxc}/share/applications/org.keepassxc.KeePassXC.desktop"
                      "applications:signal.desktop"
                      "file://${pkgs.element-desktop}/share/applications/element-desktop.desktop"
                    ];
                  };
                }
              ];
            }
          ];

          kscreenlocker = { 
            autoLock = true;
            lockOnResume = true;
            passwordRequired = true;
            timeout = 15;
            appearance = {
              alwaysShowClock = true;
              showMediaControls = true;
              wallpaper = "/run/current-system/sw/share/plasma/wallpapers/Vivid\ Wallpapers/Vivid-Line\ Wallpaper\ With\ Plasma\ Logo.png";
            };
          };

          powerdevil = { 
            AC = { 
              whenSleepingEnter = "hybridSleep";
              autoSuspend = { 
                action = "nothing";
              };
              turnOffDisplay = {
                idleTimeout = 900;
                idleTimeoutWhenLocked = "immediately";
              };
            };
            battery = { 
              whenSleepingEnter = "hybridSleep";
              autoSuspend = { 
                action = "sleep";
                idleTimeout = 900;
              };
              turnOffDisplay = {
                idleTimeout = 300;
                idleTimeoutWhenLocked = "immediately";
              };
            };
          };

          kwin = {
            effects = {
              wobblyWindows = { 
                enable = true;
              };
            };
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
            kwinrc.Desktops= {
              Number = {
                value = 9;
                # Forces kde to not change this value (even through the settings app).
                immutable = true;
              };
              Rows = {
                value = 3;
                immutable = true;
              };
            };
            klipperrc = {
              General = {
                MaxClipItems = {
                  value = 2000;
                  immutable = true;
                };
              };
            };
            kcminputrc = {
              Keyboard = {
                NumLock = {
                  value = 0;
                  immutable = true;
                };
              };
            };
            plasmaparc = {
              General = {
                AudioFeedback = {
                  value = false; # Disable audio feedback at volume change
                  immutable = true;
                };
              };
            };
            kdeglobals = {
              General = {
                TerminalApplication = { 
                  value = "alacritty";
                };
                TerminalService = {
                  value = "Alacritty.desktop";
                };
              };
            };
          };

          shortcuts = {
            "services/Alacritty.desktop" = {
              _launch = "Ctrl+Alt+T";
            };
          };
        };


        kitty = {
          enable = true;
          settings = {
            confirm_os_window_close = 0;
          };
        };
        firefox.enable = true;
        alacritty = { 
          enable = true;
          settings = {
            window.dimensions = {
              lines = 30;
              columns = 125;
            };
          };
        };
        floorp.enable = false;

        git = (mkIf cfg.git.enable {
          enable = true;
          difftastic.enable = true;
          userName = cfg.git.userName;
          userEmail = cfg.git.userEmail;
          extraConfig= {
            pull.rebase = false;
          };
        });

      };
      dconf.settings = (mkIf config.flcraft.system.virt.enable {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
        };
      });
    });
  };
}