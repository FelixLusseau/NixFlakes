{ pkgs, ... }:
{
  home.stateVersion = "24.05";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "felix";
    homeDirectory = "/home/felix";
  };

  home.packages = with pkgs; [
    vscode
    discord
    # fastfetch
    google-chrome

    nixpkgs-fmt # nix formatting tool
    nix-prefetch-git

    direnv # environment variable manager

    nautilus # Cli file manager
    ranger # terminal file manager
    fd # replacement for find

    zellij # tmux alternative

    font-manager

    glow # markdown previewer in terminal
    btop # replacement of htop/nmo
    iotop # io monitoring
    iftop # network monitoring
    ncdu

    ani-cli
    spicetify-cli
    spotify

    # Terminal
    # tree
    # nnn # terminal file manager
    # bat # replacement for cat
    # eza # A modern replacement for ‘ls’
    # fzf # A command-line fuzzy finder
    # broot
    # libnotify
    # difftastic

    wl-clipboard
    wf-recorder

    w3m # Display image in terminal
    ueberzug
    # archives
    zip
    unzip


    brightnessctl # control screen brightness

    # Other
    # cowsay
    xclip
    # ripgrep

    signal-desktop
    element-desktop
    brave
    keepassxc
    gimp
    vlc
    # libreoffice
    bruno
    xournalpp
    # figlet
    # lolcat

    python3

    dnsutils
    plocate

  ];

  # nixpkgs.overlays = [
  #   (self: super: {
  #     zsh-forgit              = super.callPackage ../modules/shell/zsh/plugin/zsh-forgit.nix { };
  #     zsh-autopair            = super.callPackage ../modules/shell/zsh/plugin/zsh-autopair.nix { };
  #     zsh-auto-notify         = super.callPackage ../modules/shell/zsh/plugin/zsh-auto-notify.nix { };
  #     zsh-fzf-history-search  = super.callPackage ../modules/shell/zsh/plugin/zsh-fzf-history-search.nix { };
  #   })
  # ];

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
          theme = "Vivid-Dark-Global-6";
        };
        wallpaper = "/home/felix/.local/share/wallpapers/Vivid-Line-Wallpaper-With-Plasma-Logo.png";
      };

      panels = [
        # Windows-like panel at the top
        {
          location = "top";
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

      # kwin = {
      #   nightLight = {
      #     enable = true;
      #     mode = "times";
      #     temperature = {
      #       day = 6500;
      #       night = 4500;
      #     };
      #     time = {
      #       evening = "21:00";
      #       morning = "07:00";
      #     };
      #   };
      # };
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
    # fzf.enable = true; # enables zsh integration by default
    # starship.enable = true;
    # command-not-found.enable = true;

    # zsh = {
    #   enable = true;
    #   enableCompletion = true;
    #   autosuggestion.enable = true;
    #   syntaxHighlighting.enable = true;

    #   shellAliases = {
    #     nixswitch = "sudo nixos-rebuild switch";
    #     nixconfig = "$EDITOR /etc/nixos/";
    #     cd = "z";
    #     ls = "eza --icons --group-directories-first";
    #     ll = "eza --icons -l --group-directories-first";
    #     tree = "eza --tree --icons";
    #     cat = "bat";
    #     clip = "wl-copy";
    #     whatismyip = "curl https://ipinfo.io/ip";
    #     mtr = "mtr -e -b -t -z";
    #   };

    #   initExtra = "fastfetch\nfiglet -c FLNix | lolcat\n";

    #   oh-my-zsh = {
    #     enable = true;
    #     plugins = [
    #       "git"
    #       "node"
    #       "npm"
    #       "sudo"
    #       "forgit"
    #       "docker"
    #       "battery"
    #       "kubectl"
    #       "autopair"
    #       "colorize"
    #       "auto-notify"
    #       "colored-man-pages"
    #       "command-not-found"
    #       "zsh-interactive-cd"
    #       "zsh-fzf-history-search"
    #       "history-substring-search"
    #     ];
    #     # customPkgs = with pkgs; [
    #     #   # zsh-forgit
    #     #   # zsh-fzf-history-search
    #     #   # zsh-autopair
    #     #   # zsh-auto-notify
    #     # ];
    #     theme = "af-magic";
    #   };
    # };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # helix = {
    #   enable = true;
    #   settings = { theme = lib.mkDefault "nord"; };
    #   themes = {
    #     nord = {
    #       inherits = "nord";
    #       "ui.background" = "none";
    #     };
    #   };
    # };
  };
}