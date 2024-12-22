{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ./pkgs.nix {
      cores-nb = config.flcraft.system.hardware.cores-nb;
      wifi-int-name = config.flcraft.system.hardware.wifi-int-name;
    })
  ];
}
