# Config of swaylock, screen locker utility for Sway

{ config, lib, ... }:

let
  inherit (config.my.desktop.theme) background termFont topBar;
  cfg = config.my.desktop.swaylock;
in
{
  options.my.desktop.swaylock.enable = lib.mkEnableOption "swaylock";

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      configFile."swaylock/config".text = with config.colorScheme.palette; ''
        show-keyboard-layout
        indicator-caps-lock
        image=${background.path}
        scaling=${background.scaling}
        font=${termFont.name} ${termFont.style}
        font-size=${toString (topBar.fontSize * 2)}
        indicator-radius=100
        indicator-thickness=20
        bs-hl-color=${base08}
        inside-color=${base00}
        inside-clear-color=${base0A}
        inside-ver-color=${base0D}
        inside-wrong-color=${base08}
        key-hl-color=${base0A}
        layout-bg-color=${base00}
        layout-border-color=${base00}
        layout-text-color=${base05}
        ring-color=${base00}
        ring-clear-color=${base0A}
        ring-ver-color=${base0D}
        ring-wrong-color=${base08}
        separator-color=${base00}
        text-color=${base00}
        text-clear-color=${base00}
        text-ver-color=${base00}
        text-wrong-color=${base00}
      '';
    }; # xdg
  }; # config
}
