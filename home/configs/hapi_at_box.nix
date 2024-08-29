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
      export NIXOS_OZONE_WL=1
    '';
    
    extraOptions = lib.mkAfter [ "--unsupported-gpu" ];
    # You can find these names by `running swaymsg -t get_outputs` in a terminal
    # when Sway is running.
    extraConfig = lib.mkAfter ''
      output "Unknown-1" {
          mode 2560x1440@60Hz
              position 0,0
          }
          
      output "Unknown-2" {
          mode 1920x1080@60Hz
          position -1920,0
      }
          
      output * mirror none
      
      workspace 1 output "Unknown-1"
      workspace 2 output "Unknown-2"
      resolution 1920x1080 position 0,0
    '';
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
