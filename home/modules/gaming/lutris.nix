{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.lutris;
in
{
  options.my.gaming.lutris = with lib; {
    enable = mkEnableOption "Lutris";
  };

  config = lib.mkIf cfg.enable {
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
    programs.lutris.enable = true;
  };
}
