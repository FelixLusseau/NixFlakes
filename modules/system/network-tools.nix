{ config, lib, pkgs, ... }:

let cfg = config.flcraft.system;
in
with lib;
with types;
{
  config = mkMerge [
    (mkIf cfg.network-tools.enable
      {
        environment.systemPackages = with pkgs; [
          nmap
          tcpdump
        ];
      }
    )
  ];
}