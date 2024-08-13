{ inputs, config, pkgs, lib, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [ inputs.self.homeModules.default ./user.nix ];

  my = {
    desktop = {
      enable = true;
    };
    gaming.wine.enable = true;
  };

  wayland.windowManager.sway = {
    extraSessionCommands = lib.mkAfter ''
      export WLR_NO_HARDWARE_CURSORS=1
      export WLR_DRM_DEVICES=/dev/dri/card0
    '';
    extraOptions = lib.mkAfter [ "--unsupported-gpu" ];
  };

  home.stateVersion = "24.05";

  # services.kanshi.profiles = {
  #   undocked = {
  #     outputs = [
  #       { criteria = "eDP-1"; }
  #     ];
  #   };
  #   docked = {
  #     outputs = [
  #       {
  #         criteria = "eDP-1";
  #         position = "1920,0";
  #       }
  #       {
  #         # Use make-model-serial criterion for external monitors as the name
  #         # (DP-?) may change when reconnected. Get it using:
  #         #     swaymsg -t get_outputs
  #         criteria = "Iiyama North America PL2493H 1211424213213";
  #         position = "0,0";
  #       }
  #     ];
  #   };
  # };
}
