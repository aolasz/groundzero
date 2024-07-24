{ lib, ... }:

{
  imports = [
    ./core
    ./desktop
    ./gaming
    ./virtualization
  ];

  options.my = {
    flakeURI = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "github:aolasz/groundzero";
      description = ''
        URI of the NixOS configuration flake. Can be set to point to a local
        repository, too.
      '';
    };

    primaryDisplayResolution = {
      horizontal = lib.mkOption {
        type = lib.types.int;
        default = 1920;
        description = ''
          Horizontal resolution of the primary display. Used for desktop
          background image generation and scaling of UI elements & fonts.
        '';
      };
      vertical = lib.mkOption {
        type = lib.types.int;
        default = 1080;
        description = ''
          Vertical resolution of the primary display. Used for desktop
          background image generation and scaling of UI elements & fonts.
        '';
      };
    };

    hwBrightnessControl = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        True if brightness control keys control brightness through hardware.
      '';
    };
  };
}
