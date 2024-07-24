{ config, lib, ... }:

let
  cfg = config.my.desktop.swaywm;
in
{
  options.my.desktop.swaywm = {
    enable = lib.mkEnableOption "system-level Sway config";
  };

  config = lib.mkIf cfg.enable {
    programs.dconf.enable = lib.mkDefault true;

    environment.loginShellInit = ''
      if command -v sway > /dev/null &&
         [ -z $DISPLAY ] &&
         [ -z $WAYLAND_DISPLAY ] &&
         [ "$(tty)" = "/dev/tty1" ]
      then
        exec sway
      fi
    '';
  };
}
