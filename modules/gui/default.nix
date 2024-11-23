{ config, pkgs, lib, ... }:

let cfg = config.flcraft.gui;
in
with lib;
with types;

{
  imports =
  [
    ./packages.nix
  ];
}