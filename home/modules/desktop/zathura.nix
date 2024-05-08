# Config of the zathura document viewer

{ config, lib, ... }:

let
  cfg = config.my.desktop.zathura;
in
{
  options.my.desktop.zathura.enable = lib.mkEnableOption "zathura";

  config = lib.mkIf cfg.enable {
    programs.zathura.enable = true;

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs [
          "application/pdf" # .pdf
          "application/postscript" # .ps .eps .ai
          "image/x-eps" # .eps
          "image/vnd.djvu" # .djvu
        ] (_: [ "org.pwmt.zathura.desktop" ]);
      }; # mimeApps
    }; # xdg
  }; # config
}
