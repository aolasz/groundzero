# Config of the Inkscape vector graphics editor

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.obsidian;
in
{
  options.my.desktop.obsidian.enable = lib.mkEnableOption "Obsidian notes";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
      obsidian-export
    ];
  }; # config
}
