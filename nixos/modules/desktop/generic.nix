{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.generic;
in
{
  options.my.desktop.generic = {
    enable = lib.mkEnableOption "generic system-level desktop settings";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        polkit_gnome # for a Policy Kit authentication agent
      ];

      # Make applications find files in <prefix>/share
      pathsToLink = [ "/share" "/libexec" ];
    };

    fonts.enableDefaultPackages = lib.mkDefault true;

    hardware.bluetooth = {
      enable = true;
      # WORKAROUND: fix bluetooth SAP (SIM Access Profile) related errors
      disabledPlugins = [ "sap" ];
    };

    security.rtkit.enable = true;

    services = {
      upower.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
  };
}
