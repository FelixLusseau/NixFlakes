{ config, lib, pkgs, ... }:

let cfg = config.flcraft.shell.zsh;
in
with lib;
with types;
{
  config = mkMerge [
    (mkIf cfg.enable {
      nixpkgs.overlays = [
        (self: super: {
          zsh-forgit              = super.callPackage ./plugin/zsh-forgit.nix { };
          zsh-autopair            = super.callPackage ./plugin/zsh-autopair.nix { };
          zsh-auto-notify         = super.callPackage ./plugin/zsh-auto-notify.nix { };
          zsh-fzf-history-search  = super.callPackage ./plugin/zsh-fzf-history-search.nix { };
        })
      ];

      programs.command-not-found.enable = true;
      environment.systemPackages = with pkgs; [
        bat
        ripgrep
        fzf
        libnotify
        difftastic
        fastfetch
        eza
        tree
        cowsay
        nnn
        broot
        figlet
        lolcat
        direnv
        ranger # terminal file manager
        fd # replacement for find
        zellij # tmux alternative
        glow # markdown previewer in terminal
        btop # replacement of htop/nmo
        iotop # io monitoring
        iftop # network monitoring
        ncdu
        w3m # Display image in terminal
        plocate
        duf
      ];
      programs = {
        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
            nixswitch = "sudo nixos-rebuild switch";
            nixconfig = "$EDITOR /etc/nixos/";
            # cd = "z";
            ls = "eza --icons --group-directories-first";
            ll = "eza --icons -l --group-directories-first";
            tree = "eza --tree --icons";
            cat = "bat";
            clip = "wl-copy";
            whatismyip = "curl https://ipinfo.io/ip";
            mtr = "mtr -e -b -t -z";
          };

          promptInit = "${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin\nfastfetch\nfiglet -c FLNix | lolcat\n";

          ohMyZsh = {
            enable = true;
            plugins = [
              "git"
              "node"
              "npm"
              "sudo"
              "forgit"
              "docker"
              "battery"
              "kubectl"
              "autopair"
              "colorize"
              "auto-notify"
              "colored-man-pages"
              "command-not-found"
              "zsh-interactive-cd"
              "zsh-fzf-history-search"
              "history-substring-search"
            ];
            customPkgs = with pkgs; [
              zsh-forgit
              zsh-fzf-history-search
              zsh-autopair
              zsh-auto-notify
            ];
            theme = "af-magic";
          };
        };
      };
      environment.etc.zshrc.text = ''
        source ${./zshrc.sh}
      '';

      # Set as user shell.
      users = {
        defaultUserShell = pkgs.zsh;
        #users.root.shell = pkgs.zsh;
      };
    })
  ];
}
