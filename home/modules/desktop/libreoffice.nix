# Config of the LibreOffice office suite

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.libreOffice;
in
{
  options.my.desktop.libreOffice.enable = lib.mkEnableOption "LibreOffice";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.libreoffice ];

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        # Based on:
        # https://git.libreoffice.org/core/+/refs/tags/libreoffice-24.2.3.1/sysui/desktop/menus/
        # https://git.libreoffice.org/core/+/refs/tags/libreoffice-24.2.3.1/sysui/desktop/mimetypes/
        defaultApplications = (
          lib.genAttrs [
            "application/csv" # .csv
            "application/vnd.ms-excel" # .xls
            "application/vnd.ms-excel.sheet.binary.macroEnabled.12" # .xlsb
            "application/vnd.ms-excel.sheet.macroEnabled.12" # .xlsm
            "application/vnd.ms-excel.template.macroEnabled.12" # .xltm
            "application/vnd.oasis.opendocument.chart" # .odc
            "application/vnd.oasis.opendocument.chart-template" # .otc
            "application/vnd.oasis.opendocument.spreadsheet" # .ods
            "application/vnd.oasis.opendocument.spreadsheet-flat-xml" # .fods
            "application/vnd.oasis.opendocument.spreadsheet-template" # .ots
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" # .xlsx
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template" # .xltx
            "text/csv" # .csv
          ] (_: [ "calc.desktop" ])
        ) // (
          lib.genAttrs [
            "application/rtf" # .rtf
            "application/msword" # .doc
            "application/vnd.ms-word" # .doc
            "application/vnd.ms-word.document.macroEnabled.12" # .docm
            "application/vnd.ms-word.template.macroEnabled.12" # .dotm
            "application/vnd.oasis.opendocument.text" # .odt
            "application/vnd.oasis.opendocument.text-flat-xml" # .fodt
            "application/vnd.oasis.opendocument.text-master" # .odm
            "application/vnd.oasis.opendocument.text-master-template" # .otm
            "application/vnd.oasis.opendocument.text-template" # .ott
            "application/vnd.oasis.opendocument.text-web" # .oth
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document" # .docx
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template" # .dotx
            "text/rtf" # .rtf
          ] (_: [ "writer.desktop" ])
        ) // (
          lib.genAttrs [
            "application/vnd.ms-powerpoint" # .ppt
            "application/vnd.ms-powerpoint.presentation.macroEnabled.12" # .pptm
            "application/vnd.ms-powerpoint.template.macroEnabled.12" # .potm
            "application/vnd.oasis.opendocument.presentation" # .odp
            "application/vnd.oasis.opendocument.presentation-flat-xml" # .fodp
            "application/vnd.oasis.opendocument.presentation-template" # .otp
            "application/vnd.openxmlformats-officedocument.presentationml.presentation" # .pptx
            "application/vnd.openxmlformats-officedocument.presentationml.template" # .potx
          ] (_: [ "impress.desktop" ])
        ) // (
          lib.genAttrs [
            "application/vnd.oasis.opendocument.graphics" # .odg
            "application/vnd.oasis.opendocument.graphics-flat-xml" # .fodg
            "application/vnd.oasis.opendocument.graphics-template" # .otg
            "application/vnd.visio" # .vsd
            "application/vnd.corel-draw" # .cdr
            "application/vnd.ms-publisher" # .pub
            # "application/pdf" # .pdf
            "image/emf" # .emf
            "image/x-emf" # .emf
            "image/wmf" # .wmf
            "image/x-wmf" # .wmf
          ] (_: [ "draw.desktop" ])
        ) // (
          lib.genAttrs [
            "application/vnd.oasis.opendocument.formula" # .odf
            "application/vnd.oasis.opendocument.formula-template" # .otf
            "text/mathml" # .mml
            "application/mathml+xml" # .mml
          ] (_: [ "math.desktop" ])
        );
      }; # mimeApps
    }; # xdg
  }; # config
}
