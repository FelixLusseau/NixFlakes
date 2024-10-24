{config, lib, packages, ...}:
let
  cfg = config.shincraft.shell;
in
with lib;
{
  imports =
  [
    ./zsh
  ];
}
