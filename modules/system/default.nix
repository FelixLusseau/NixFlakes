{config, lib, packages, ...}:
let
  cfg = config.flcraft.system;
in
with lib;
{
  imports =
  [
    ./splash
    ./ssh.nix
  ];
}