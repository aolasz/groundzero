{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.steam;
in
{
  options.my.gaming.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    # my.gaming.mangohud.enable = lib.mkForce true;
    # my.gaming.protonup.enable = lib.mkForce true;
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
  };
}
