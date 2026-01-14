{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.default
    ./user.nix
  ];

  my = {
    desktop = {
      enable = true;
      onlyoffice = {
        enable = true;
        sharepoint.enable = true;
        sharepoint.siteUrl = "https://furukawaelectric.sharepoint.com/sites/feti";
        cache.maxSize = 5120; # 5 GB cache for large files
        network.connectionTimeout = 600; # 10 minutes for slow connections
      };
    };
    gaming.wine.enable = true;
    gaming.lutris.enable = true;
    gaming.protonup.enable = true;
  };

  home = {
    packages = with pkgs; [
      vulkan-tools
      vulkan-loader
      vulkan-headers
      vulkan-validation-layers
      libva-utils
      vdpauinfo
      libvdpau-va-gl
      egl-wayland
      wgpu-utils
      mesa
      libglvnd
      nvtopPackages.full
      nvitop
      libGL
      mesa-demos
    ];
    sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      NVK_USE_MESA_OVERLAY_LAYER = "0";
      LIBGL_ALWAYS_INDIRECT = "0";
      NVD_BACKEND = "direct";
      # Already defined home/modules/desktop/generic.nix
      # SDL_VIDEODRIVER = "wayland,x11"; # Allow fallback to X11
    };
    shellAliases = {
      # signal-desktop = "env -u WAYLAND_DISPLAY signal-desktop";
    };
  };

  wayland.windowManager.sway = {
    extraSessionCommands = lib.mkAfter ''
      export NIXOS_OZONE_WL=1
      export WLR_DRM_DEVICES=/dev/dri/card1
      export WLR_NO_HARDWARE_CURSORS=1
      export LIBVA_DRIVER_NAME=nvidia
      export XDG_SESSION_TYPE=wayland
      export GBM_BACKEND=nvidia-drm
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export SDL_VIDEODRIVER=wayland,x11
    '';

    extraOptions = lib.mkAfter [ "--unsupported-gpu" ];
    # You can find these names by running `swaymsg -t get_outputs` in a terminal
    # when Sway is running.
    extraConfig = lib.mkAfter ''
      output "DP-3" {
          mode 2560x1440@60Hz
          position 0,0
      }

      output "DP-2" {
          mode 1920x1080@60Hz
          position -1920,0
      }

      workspace 1 output "DP-3"
      workspace 2 output "DP-2"
    '';
  };

  home.stateVersion = "24.05";

  # services.kanshi.profiles = {
  #   undocked = {
  #     outputs = [
  #       { criteria = "eDP-1"; }
  #     ];
  #   };
  #   docked = {
  #     outputs = [
  #       {
  #         criteria = "eDP-1";
  #         position = "1920,0";
  #       }
  #       {
  #         # Use make-model-serial criterion for external monitors as the name
  #         # (DP-?) may change when reconnected. Get it using:
  #         #     swaymsg -t get_outputs
  #         criteria = "Iiyama North America PL2493H 1211424213213";
  #         position = "0,0";
  #       }
  #     ];
  #   };
  # };
}
