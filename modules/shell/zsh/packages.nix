{ pkgs, ... }:
{
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
  ];
}