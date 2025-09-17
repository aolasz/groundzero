{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gaming.steam;
in {
  options.my.gaming.steam = {
    enable = lib.mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    # my.gaming.mangohud.enable = lib.mkForce true;
    # my.gaming.protonup.enable = lib.mkForce true;
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    programs.gamemode.enable = true;
    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      protonup-qt # GUI for managing custom Proton versions
      steam-run # Only if you need FHS environment for non-Steam games
    ];
  };
}
