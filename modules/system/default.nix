{config, lib, pkgs, ...}:
let
  cfg = config.flcraft.system;
in
with lib;
{
  imports =
  [
    ./splash
    ./ssh.nix
    ./network-tools.nix
  ];
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}