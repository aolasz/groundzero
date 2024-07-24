{ config, lib, ... }:

let
  cfg = config.my.desktop;
in
{
  imports = [
    ./brother-mfp.nix
    ./generic.nix
    ./swaylock.nix
    ./swaywm.nix
  ];

  options.my.desktop = {
    enable = lib.mkEnableOption "system-level config for Sway desktop";
  };

  config.my.desktop = lib.mkIf cfg.enable {
    generic.enable = lib.mkForce true;
    swaylock.enable = lib.mkForce true;
    swaywm.enable = lib.mkForce true;
  };
}
