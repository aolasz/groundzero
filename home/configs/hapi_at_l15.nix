{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  imports = [inputs.self.homeModules.default ./user.nix];

  my = {
    primaryDisplayResolution = {
      horizontal = 1920;
      vertical = 1080;
    };
    desktop.enable = true;
    gaming.wine.enable = true;
  };

  home.stateVersion = "23.11";

  services.kanshi.settings = [
    {
      profile = {
        name = "undocked";
        outputs = [
          {criteria = "eDP-1";}
        ];
      };
    }
    {
      profile = {
        name = "feti";
        outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            # Use make-model-serial criterion for external monitors as the name
            # (DP-?) may change when reconnected. Get it using:
            #     swaymsg -t get_outputs
            # criteria = "LG Electronics LG FULL HD 0x01010101";
            criteria = "HDMI-A-1";
            position = "-1920,0";
          }
          {
            # Use make-model-serial criterion for external monitors as the name
            # (DP-?) may change when reconnected. Get it using:
            #     swaymsg -t get_outputs
            criteria = "DP-5";
            position = "-3840,0";
          }
        ];
      };
    }
  ];
}
