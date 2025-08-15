{ config, pkgs, lib, ... }:

let
  cfg = config.my.virtualization;
in
{
  options.my.desktop.blender = {
    enable = lib.mkEnableOption "3D Creation/Animation/Publishing System";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ blender ];
  };
}
