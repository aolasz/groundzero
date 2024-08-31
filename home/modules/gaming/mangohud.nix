{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.mangohud;
in
{
  options.my.gaming.mangohud = with lib; {
    enable = mkEnableOption "MangoHUD for gaming";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      mangohud
    ];
  };
}
