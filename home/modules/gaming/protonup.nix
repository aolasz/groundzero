{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.protonup;
in
{
  options.my.gaming.protonup = with lib; {
    enable = mkEnableOption "Protonup for Steam";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      protonup
    ];

    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = 
        "\${HOME}/.steam/root/compatibilitytools.d";
    };
  };
}
