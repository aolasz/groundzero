{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gaming.heroic;
in {
  options.my.gaming.heroic = {
    enable = lib.mkEnableOption "Heroic Games Launcher";
    enableGamescope = lib.mkEnableOption "Gamescope support for Heroic";
    extraPkgs = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Extra packages to include in Heroic's FHS environment";
    };
  };
  config = lib.mkIf cfg.enable {
    # my.gaming.mangohud.enable = lib.mkForce true;
    # my.gaming.protonup.enable = lib.mkForce true;

    # Install Heroic with optional extra packages
    environment.systemPackages = with pkgs; [
      (
        if cfg.extraPkgs != []
        then heroic.override {extraPkgs = pkgs: cfg.extraPkgs;}
        else heroic
      )
    ];

    # Enable GameMode for better gaming performance
    programs.gamemode.enable = true;

    # Optionally enable Gamescope
    programs.gamescope.enable = lib.mkIf cfg.enableGamescope true;
  };
}
