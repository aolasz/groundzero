# Config of the Inkscape vector graphics editor

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.inkscape;
in
{
  options.my.desktop.inkscape.enable = lib.mkEnableOption "Inkscape";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.inkscape ];

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        # Based on:
        # https://gitlab.com/inkscape/inkscape/-/raw/091e20ef0f204eb40ecde54436e1ef934a03d894/share/CMakeLists.txt
        defaultApplications = lib.genAttrs [
          "image/svg+xml"
          "image/svg+xml-compressed"
          # "application/vnd.corel-draw"
          # "application/pdf"
          # "application/postscript"
          # "image/x-eps"
          # "application/illustrator"
          # "image/x-wmf"
          # "image/x-emf"
          # "application/x-xccx"
          # "application/x-xcdt"
          # "application/x-xcmx"
          # "image/x-xcdr"
          # "application/visio"
          # "application/x-visio"
          # "application/vnd.visio"
          # "application/vnd.ms-visio.viewer"
          # "application/visio.drawing"
          # "application/vsd"
          # "application/x-vsd"
          # "image/x-vsd"
        ] (_: [ "org.inkscape.Inkscape.desktop" ]);
      }; # mimeApps
    }; # xdg
  }; # config
}
