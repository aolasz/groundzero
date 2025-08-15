{ config, pkgs, lib, ... }: {

options.my.desktop.swaylock = {
  enable = lib.mkEnableOption "3D Creation/Animation/Publishing System";
};
environment.systemPackages = with pkgs; [
  blender
];
}
