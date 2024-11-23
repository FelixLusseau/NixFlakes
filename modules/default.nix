{ lib, ... }:

with lib;
with types;
{
  imports = [
    ./shell
    ./system
    ./gui
  ];

  options.flcraft = {
    shell = {
      # vim.enable    = mkEnableOption "Activate Vim advenced config";
      # nixvim.enable = mkEnableOption "Activate NeoVim advenced config";
      # tmux.enable   = mkEnableOption "Activate tmux advenced config";
      zsh = {
        enable = mkEnableOption "Activate ZSH as default shell";
      };
    };
    system = {
      ssh.enable = mkEnableOption "Activate SSH server";
    };
    gui = {
      enable = mkEnableOption "Activate GUI";
      pkgs = {
        messages.enable = mkEnableOption "Activate messages apps";
        programming.enable = mkEnableOption "Activate programming";
        art.enable = mkEnableOption "Activate image and video editing";
      };
    };
  };
}
