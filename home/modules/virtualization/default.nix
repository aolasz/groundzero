{ config, lib, ... }:

let
  cfg = config.my.virtualization;
in
{
  options.my.virtualization = {
    enable = lib.mkEnableOption "virtualization";
  };

  config = lib.mkIf cfg.enable { };
}
