{ inputs, config, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = [ inputs.self.homeModules.default ./user.nix ];

  my = {
    primaryDisplayResolution = { horizontal = 1920; vertical = 1080; };
    desktop.enable = true;
    gaming.wine.enable = true;
  };

  home.stateVersion = "23.11";

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
