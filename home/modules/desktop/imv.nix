# Config of the imv command-line image viewer

{ config, pkgs, lib, ... }:

let
  inherit (config.my.desktop.theme) termFont topBar;
  cfg = config.my.desktop.imv;
  font = "${termFont.name}:${toString topBar.fontSize}";
in
{
  options.my.desktop.imv.enable = lib.mkEnableOption "imv";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.imv ];

    xdg = {
      enable = true;
      configFile."imv/config".text =
        let
          n = "[$imv_current_index/$imv_file_count]";
          r = "[\${imv_width}x\${imv_height}]";
          s = "[\${imv_scale}%]";
          p = "$(realpath --relative-to=. \"$imv_current_file\")";
        in
        ''
          [options]
          overlay = true
          overlay_font = ${font}
          overlay_text = ${n} ${r} ${s} ${p}
        '';
      mimeApps = {
        enable = true;
        # Based on:
        # https://git.sr.ht/~exec64/imv/blob/v4.5.0/files/imv.desktop
        defaultApplications = lib.genAttrs [
          "image/bmp" # .bmp
          "image/gif" # .gif
          "image/jpeg" # .jpeg
          "image/jpg" # .jpg
          "image/pjpeg" # .pjpg
          "image/png" # .png
          "image/tiff" # .tif .tiff
          "image/x-bmp" # .bmp
          "image/x-pcx" # .pcx
          "image/x-png" # .png
          "image/x-portable-anymap" # .pnm
          "image/x-portable-bitmap" # .pbm
          "image/x-portable-graymap" # .pgm
          "image/x-portable-pixmap" # .ppm
          "image/x-tga" # .tga
          "image/x-xbitmap" # .xbm
          "image/heif" # .heif
          "image/avif" # .heif
        ] (_: [ "imv.desktop" ]);
      }; # mimeApps
    }; # xdg
  }; # config
}
