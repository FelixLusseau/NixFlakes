{ lib, ... }:

with lib;
with types;
{
    imports = [
    ./shell
    ./splash
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
  };
}
