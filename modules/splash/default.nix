{ config, lib, ... }:

{
  nixpkgs.overlays = [(self: super: {
    splash-boot = super.callPackage ./pkgs.nix {
      theme = config.boot.plymouth.theme;
      # logo = config.boot.plymouth.logo;
    };
  })];
}
