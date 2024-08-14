# Config of the FreeTube desktop application to browse YouTube more privately

{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop.freetube;
in
{
  options.my.desktop.freetube.enable = lib.mkEnableOption "freetube";

  config = lib.mkIf cfg.enable {
    home.file = {
      ".config/FreeTube/player_cache/.keep".text = "";
    };
    programs.freetube = {
      enable = true;
      package = pkgs.freetube.override {
        electron = pkgs.electron.overrideAttrs (oldAttrs: {
          extraArgs = "--enable-features=VaapiVideoDecoder --use-gl=desktop --ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy";
        });
      };
      # imperative settings can be found in $XDG_CONFIG_HOME/FreeTube/settings.db
      settings = {
        allowDashAv1Formats = true;
        checkForUpdates = false;
        externalPlayer = "mpv";
        externalPlayerExecutable = "mpv";
        externalPlayerCustomArgs = lib.strings.concatStringsSep "; " [
          "--vo=x11"
          "--audio-buffer=0.5"
          "--profile=low-latency"
          "--hwdec=auto"
          "--ytdl-format='bestvideo[vcodec^=avc1][height<=?1440][fps<=?60]+bestaudio'"
          "--profile=gpu-hq"
          "--scale=ewa_lanczossharp"
          "--cscale=ewa_lanczossharp"
          "--save-position-on-quit"
        ];
        defaultQuality = "1080";
        baseTheme = "system";
        mainColor = "DeepOrange";
        secColor = "Orange";
        allSettingsSectionsExpandedByDefault = false;
        expandSideBar = true;
        hideHeaderLogo = true;
        hideLabelsSideBar = false;
        downloadBehavior = "download";
        useSponsorBlock = true;
      }; # settings
    }; # freetube
  }; # config
}
