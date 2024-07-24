{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.wine;
in
{
  options.my.gaming.wine = with lib; {
    enable = mkEnableOption "Wine gaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wineWowPackages.waylandFull
      # wineWowPackages.full
      wineWowPackages.fonts
    ];
  };
}
