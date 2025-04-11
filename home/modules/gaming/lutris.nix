{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gaming.lutris;
in {
  options.my.gaming.lutris = {
    enable = lib.mkEnableOption "Lutris";
  };

  config = lib.mkIf cfg.enable {
    my.gaming.wine.enable = lib.mkForce true;
    my.gaming.mangohud.enable = lib.mkForce true;

    home.sessionVariables = {
      # General Vulkan setup
      VK_LAYER_PATH = "${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d";

      # For 32-bit applications
      VK_LAYER_PATH_32 = "${pkgs.pkgsi686Linux.vulkan-validation-layers}/share/vulkan/explicit_layer.d";

      # For NVIDIA specifically
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    home.packages = with pkgs; [
      lutris
      # vulkan-tools
      # vulkan-loader
      # vulkan-validation-layers
      # GOG-related packages
      gogdl # GOG downloader
      lgogdownloader # Another GOG downloader
      innoextract # Used to extract GOG installers
      p7zip
      cabextract # For extracting CAB files (used by some GOG games)
    ];
  };
}
