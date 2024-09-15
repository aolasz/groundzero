{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.lutris;
in
{
  options.my.gaming.lutris = {
    enable = lib.mkEnableOption "Lutris";
  };


  config = lib.mkIf cfg.enable {
    my.gaming.wine.enable = lib.mkForce true;
    my.gaming.mangohud.enable = lib.mkForce true;

    home.packages = with pkgs; [
      lutris
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
      # GOG-related packages
      gogdl  # GOG downloader
      lgogdownloader  # Another GOG downloader
      innoextract  # Used to extract GOG installers
      p7zip
      cabextract  # For extracting CAB files (used by some GOG games)
    ];
  };
}
