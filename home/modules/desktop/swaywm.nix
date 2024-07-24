{ config, lib, pkgs, ... }:

let
  inherit (config.my.desktop.theme)
    cursorTheme
    termFont
    topBar
    background
    ;

  cfg = config.my.desktop.swaywm;

  hwBrCtl = config.my.hwBrightnessControl;

  # Python enviromnent for Sway
  swayPythonEnv = pkgs.python3.withPackages (
    ps: with pkgs; with ps; [ i3ipc msgpack ]
  );

  # Utilities and scripts
  xargs = "${pkgs.findutils}/bin/xargs";
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";
  swaylock = "${pkgs.swaylock}/bin/swaylock -f";

  scripts = (import ./scripts.nix { inherit pkgs; }) //
    (import ./swaywm/scripts.nix { inherit lib pkgs; });

  mkCmdFunc = cmd: op: "exec ${cmd} ${op}";

  screenshotCmd = mkCmdFunc
    "${scripts.my-sway-screenshot}/bin/my-sway-screenshot";
  volumeCmd = mkCmdFunc "${scripts.my-volume}/bin/my-volume";
  # Ignore brightness changes if controlled by hardware
  brightnessCmd = op:
    (mkCmdFunc "${scripts.my-brightness}/bin/my-brightness")
      (if hwBrCtl then "get" else op)
  ;

  # Modifiers
  mod = "Mod4";
  altMod = "Mod1";

  bindingModes = import ./swaywm/modes.nix { inherit config pkgs lib mod; };
in
{
  options.my.desktop.swaywm = with lib; {
    enable = mkEnableOption "Sway window manager";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      xwayland = true;
      extraSessionCommands = ''
        export XDG_CURRENT_DESKTOP=sway
        # https://github.com/swaywm/sway/issues/595
        export _JAVA_AWT_WM_NONREPARENTING=1
        export DESKTOP_SESSION=gnome
        export SSH_AUTH_SOCK
      '';
      config = rec {
        fonts = {
          names = [ termFont.name ];
          style = termFont.style;
          size = topBar.fontSize + 0.0; # Convert to float
        };

        menu = "${pkgs.bemenu}/bin/bemenu-run | ${xargs} ${swaymsg} exec --";

        terminal = "${pkgs.foot}/bin/footclient";

        bars = [
          {
            inherit fonts;
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
            trayOutput = null;
            extraConfig = ''
              height ${toString topBar.height}
              status_padding 0
            '';
            colors = with config.colorScheme.palette; {
              separator = "#${base05}";
              background = "#${base00}";
              statusline = "#${base05}";
              focusedWorkspace = {
                border = "#${base0A}";
                background = "#${base0A}";
                text = "#${base00}";
              };
              activeWorkspace = {
                border = "#${base05}";
                background = "#${base05}";
                text = "#${base00}";
              };
              inactiveWorkspace = {
                border = "#${base00}";
                background = "#${base00}";
                text = "#${base05}";
              };
              urgentWorkspace = {
                border = "#${base08}";
                background = "#${base08}";
                text = "#${base00}";
              };
              bindingMode = {
                border = "#${base07}";
                background = "#${base07}";
                text = "#${base00}";
              };
            };
          }
        ]; # bars

        colors = with config.colorScheme.palette; {
          background = "#${base0A}";
          focused = {
            border = "#${base0A}";
            background = "#${base0A}";
            text = "#${base00}";
            indicator = "#${base0A}";
            childBorder = "#${base0A}";
          };
          focusedInactive = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          placeholder = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          unfocused = {
            border = "#${base03}";
            background = "#${base03}";
            text = "#${base05}";
            indicator = "#${base05}";
            childBorder = "#${base03}";
          };
          urgent = {
            border = "#${base08}";
            background = "#${base08}";
            text = "#${base00}";
            indicator = "#${base08}";
            childBorder = "#${base08}";
          };
        }; # colors

        focus.followMouse = false;

        floating = {
          border = 1;
          criteria = [
            { title = "Password Required - Mozilla Firefox"; }
            { app_id = "pavucontrol"; }
            { class = "XEyes"; }
            { class = "Lxappearance"; }
            { app_id = "foot-floating"; }
            { title = "Need For Speed"; }
          ];
          titlebar = false;
        }; # floating

        input = {
          "*" = {
            xkb_layout = "us,hu";
            xkb_options = "ctrl:nocaps,grp:alt_shift_toggle";
          };
        }; # input

        modifier = mod;
        left = "h";
        down = "j";
        up = "k";
        right = "l";

        keybindings = lib.mkOptionDefault (
          {
            # Cancel default keybindings to not have "workspace 10"
            "${mod}+0" = null;
            "${mod}+Shift+0" = null;

            # Move workspaces between monitors
            "${mod}+${altMod}+${left}" = "move workspace to output left";
            "${mod}+${altMod}+${down}" = "move workspace to output down";
            "${mod}+${altMod}+${up}" = "move workspace to output up";
            "${mod}+${altMod}+${right}" = "move workspace to output right";
            "${mod}+${altMod}+Left" = "move workspace to output left";
            "${mod}+${altMod}+Down" = "move workspace to output down";
            "${mod}+${altMod}+Up" = "move workspace to output up";
            "${mod}+${altMod}+Right" = "move workspace to output right";

            # Audio and brightness controls
            # HACK: include --locked in the key name to enable these bindings
            # even if the screen is locked.
            "--locked XF86AudioRaiseVolume" = volumeCmd "raise";
            "--locked XF86AudioLowerVolume" = volumeCmd "lower";
            "--locked XF86AudioMute" = volumeCmd "toggle-mute";
            "--locked XF86AudioMicMute" = volumeCmd "toggle-mute-mic";
            "--locked XF86MonBrightnessUp" = brightnessCmd "raise";
            "--locked XF86MonBrightnessDown" = brightnessCmd "lower";

            # Screenshot
            "${mod}+Print" = screenshotCmd "screen";
            "${mod}+Shift+Print" = screenshotCmd "focused";
            "${mod}+Shift+s" = screenshotCmd "copy-area";
          } // bindingModes.keybindings
        ); # keybindings

        # Binding modes
        modes = lib.mkOptionDefault bindingModes.modes;

        output = {
          "*" = with config.colorScheme.palette; {
            bg = "${background.path} ${background.scaling} #${base00}";
          };
        }; # output

        seat = {
          "*" = {
            "xcursor_theme" =
              "${cursorTheme.name} ${toString cursorTheme.size}";
          };
        }; # seat

        startup = [
          # This ensures all user units started after the command (not those
          # already running) set the variables
          # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
          {
            command =
              let
                dbusCmd = "${pkgs.dbus}/bin/dbus-update-activation-environment";
                vars = [ "DISPLAY" "WAYLAND_DISPLAY" "SWAYSOCK" ];
                varsStr = lib.concatStringsSep " " vars;
              in
              ''
                systemctl --user import-environment ${varsStr} && \
                hash ${dbusCmd} 2>/dev/null && ${dbusCmd} --systemd ${varsStr}
              '';
          }
          {
            command = ''
              ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
            '';
          }
          {
            command = "${scripts.my-import-gsettings}/bin/my-import-gsettings";
            always = true;
          }
          {
            command = "${pkgs.autotiling}/bin/autotiling";
          }
          {
            command = "${pkgs.kanshi}/bin/kanshi";
            always = true;
          }
        ];

        assigns = {
          "9" = [{ app_id = "firefox"; }];
        };

        window = {
          border = 1;
          commands = [
            {
              command = "resize set 1600px 800px";
              criteria = { app_id = "pavucontrol"; };
            }
            {
              command = "move position center";
              criteria = { floating = true; };
            }
            {
              command = "move to workspace 8";
              criteria = {
                app_id = "firefox";
                title = "^Mozilla Firefox Private Browsing$";
              };
            }
          ];
          hideEdgeBorders = "smart";
          titlebar = false;
        };

        workspaceAutoBackAndForth = true;
      }; # config

      extraConfig = ''
        floating_maximum_size 1900 x 1000
      '';
    }; # wayland.windowManager.sway

    services.kanshi.enable = true;

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 180;
          command = ''${swaymsg} "output * dpms off"'';
          resumeCommand = ''${swaymsg} "output * dpms on"'';
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = "${pkgs.procps}/bin/pgrep swaylock || ${swaylock}";
        }
        { event = "lock"; command = swaylock; }
      ];
    };

    home.packages = with pkgs; [
      wl-clipboard # Wayland copy & paste command-line utilities
      swayPythonEnv
    ] ++ (builtins.attrValues scripts);
  }; # config
}
