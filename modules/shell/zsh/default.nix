{ config, lib, pkgs, ... }:

with lib;
let 
  cfg = config.flcraft.shell.zsh;
  userNames = builtins.attrNames (lib.filterAttrs (name: _: name != "root") config.flcraft.users);
in
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

      # programs.command-not-found.enable = true;
      programs.nix-index.enable = true;
      programs.mtr.enable = true;
      services.locate = { # https://search.nixos.org/options?channel=unstable&show=services.locate.interval&from=0&size=50&sort=relevance&type=packages&query=services.locate
        enable = true;
        package = pkgs.plocate;
      };
      users.extraGroups.plocate.members = userNames;
      
      environment.systemPackages = with pkgs; [
        bat
        broot
        btop # replacement of htop/nmon
        cowsay
        difftastic
        direnv
        duf
        eza
        fastfetch
        fd # replacement for find
        figlet
        fzf
        glances # system monitoring
        glow # markdown previewer in terminal
        htop
        neohtop
        nmon
        iftop # network monitoring
        iotop # io monitoring
        jq
        libnotify
        lolcat
        ncdu
        nnn
        ranger # terminal file manager
        ripgrep
        tldr
        tree
        w3m # Display image in terminal
        yazi # terminal file manager
        zellij # tmux alternative
        zoxide
      ];
      programs = {
        zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestions.enable = true;
          syntaxHighlighting.enable = true;

          shellAliases = {
            nixswitch = "sudo nixos-rebuild switch --flake .#$HOST";
            nixgc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
            cd = "z";
            ls = "eza --icons --group-directories-first";
            ll = "eza --icons -l --group-directories-first";
            tree = "eza --tree --icons";
            cat = "bat";
            clip = "wl-copy";
            whatismyip = "curl https://ipinfo.io/ip";
            mtr = "mtr -e -b -t -z";
            diff = "difft";
            kx    = "kubectx";
            kns     = "kubens";
            kubectl = "kubecolor";
            trip = "sudo trip -r cloudflare -z --tui-locale fr --tui-icmp-extension-mode full -e -a both";
          };

          ohMyZsh = {
            enable = true;
            plugins = [
              "git"
              "node"
              "npm"
              "sudo" # Tap ESC ESC to add sudo automatically
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
              "lxd"
              "you-should-use"
            ];
            customPkgs = with pkgs; [
              zsh-forgit
              zsh-fzf-history-search
              zsh-autopair
              zsh-auto-notify
              zsh-you-should-use
            ];
            theme = "af-magic";
          };
        };
      };
      environment.etc.zshrc.text = ''
        source ${./zshrc.sh}
      '';

      environment.variables = { 
        EDITOR = "vim";
      };

      # Prevent the new user dialog in zsh
      system.userActivationScripts.zshrc = "touch .zshrc";

      # Set as user shell.
      users = {
        defaultUserShell = pkgs.zsh;
      };

      programs.zsh.interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh | source /dev/stdin
        
        # Display before instant prompt to avoid warnings
        if [ -z ''${IN_NIX_SHELL+x} ]; then
          fastfetch
          figlet -c $HOST | lolcat 2> /dev/null
        fi
      '';
    })

    (mkIf cfg.powerlevel10k.enable {
      programs.zsh.promptInit = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${./p10k.zsh}
      '';
      
      programs.zsh.interactiveShellInit = mkAfter ''
        source ${./p10k-instant-prompt.zsh}
      '';
    })
  ];
}
