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

    nixpkgs-fmt # nix formatting tool

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

    ani-cli
    spicetify-cli
    spotify

    # Terminal
    # tree
    nnn # terminal file manager
    # bat # replacement for cat
    # eza # A modern replacement for ‘ls’
    # fzf # A command-line fuzzy finder

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
    figlet
    lolcat

    python3

    dnsutils
    plocate

  ];

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
        theme = "breeze-dark";
        colorScheme = "breeze-dark";
        lookAndFeel = "org.kde.breezedark.desktop";
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
          widgets = [
            {
              iconTasks = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "file://${pkgs.firefox}/share/applications/firefox.desktop"
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
    fzf.enable = true; # enables zsh integration by default
    starship.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        nixswitch = "sudo nixos-rebuild switch";
        nixconfig = "$EDITOR /etc/nixos/";
        cd = "z";
        ls = "eza --icons --group-directories-first";
        ll = "eza --icons -l --group-directories-first";
        tree = "eza --tree --icons";
        cat = "bat";
        clip = "wl-copy";
        whatismyip = "curl https://ipinfo.io/ip";
        mtr = "mtr -e -b -t -z";
      };

      initExtra = "fastfetch\nfiglet -c FLNix | lolcat\n";

      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "node" "npm" ];
        theme = "af-magic";
      };
    };

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