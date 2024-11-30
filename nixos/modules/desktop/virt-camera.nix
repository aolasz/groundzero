{ config, pkgs, lib, ... }:
# Usage:
# For recording a specific region:
# wf-recorder -g "$(slurp)" --muxer=v4l2 --codec=rawvideo --file=/dev/video0 -x yuv420p
#
# To verify the setup:
# v4l2-ctl --list-devices
# Virtual Camera (platform:v4l2loopback-000):
# /dev/video0
#
# To test the video feed:
# ffplay /dev/video0


# sources:
# https://nixos.wiki/wiki/Sway
# https://mynixos.com/nixpkgs/option/xdg.portal.config
# https://www.reddit.com/r/NixOS/comments/s9ytrg/xdgdesktopportalwlr_on_sway_causes_20_seconds/
# https://github.com/nix-community/home-manager/issues/1167
# https://discourse.nixos.org/t/xdg-desktop-portal-gtk-desktop-collision/35063
# https://discourse.nixos.org/t/some-loose-ends-for-sway-on-nixos-which-we-should-fix/17728
# https://discourse.nixos.org/t/xdg-desktop-portal-not-working-on-wayland-while-kde-is-installed/20919

let
  cfg = config.my.desktop.virtCamera;
in
{
  options.my.desktop.virtCamera = {
    enable = lib.mkEnableOption "Virtual camera with v4l2 and wf-recorder";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        slurp  # Select a region in a Wayland compositor
        v4l-utils  # Video 4 Linux 2 utils to record from video sources
        wf-recorder  # Utility program for screen recording of wlroots-based compositors
        xdg-desktop-portal  # Desktop integration portals for sandboxed apps
        xdg-desktop-portal-wlr  # xdg-desktop-portal backend for wlroots
      ];
    };

    services.dbus.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = ["wlr" "gtk"];
        };
        sway = {
          default = ["wlr" "gtk"];
        };
      };
    };

    boot = {
      kernelModules = [ "v4l2loopback" ];
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      extraModprobeConfig = ''
        options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
      '';
    };
  };
}
