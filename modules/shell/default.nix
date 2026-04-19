{
  config,
  lib,
  packages,
  ...
}:
let
  cfg = config.flcraft.shell;
in
with lib;
{
  imports = [
    ./zsh
  ];
}
