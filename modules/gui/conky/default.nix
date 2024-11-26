{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ./pkgs.nix {})
  ];
}
