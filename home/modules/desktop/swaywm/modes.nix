# Binding mode definitions and helper functions

{ config, pkgs, lib, mod, ... }:

let
  swaymsg = "${pkgs.sway-unwrapped}/bin/swaymsg";

  customModes = [
    {
      shortcut = "${mod}+q";
      prefix = "LEAVE";
      entries = [
        {
          shortcut = "l";
          label = "[l]ock";
          cmd = "loginctl lock-session";
        }
        {
          shortcut = "e";
          label = "[e]xit";
          cmd = "${swaymsg} exit";
        }
        {
          shortcut = "s";
          label = "[s]uspend";
          cmd = "systemctl suspend";
        }
        {
          shortcut = "r";
          label = "[r]eboot";
          cmd = "systemctl reboot";
        }
        {
          shortcut = "p";
          label = "[p]oweroff";
          cmd = "systemctl poweroff";
        }
      ];
    }
    {
      shortcut = "${mod}+Tab";
      prefix = "LAUNCH";
      entries = [
        {
          shortcut = "f";
          label = "[f]irefox";
          cmd = "${pkgs.firefox}/bin/firefox";
        }
        {
          shortcut = "n";
          label = "simple-sca[n]";
          cmd = "${pkgs.simple-scan}/bin/simple-scan";
        }
        {
          shortcut = "p";
          label = "[p]avucontrol";
          cmd = "${pkgs.pavucontrol}/bin/pavucontrol";
        }
        {
          shortcut = "m";
          label = "pcmanf[m]";
          cmd = "${pkgs.pcmanfm}/bin/pcmanfm";
        }
      ] ++ (
        lib.optional config.my.virtualization.enable {
          shortcut = "v";
          label = "[v]irt-manager";
          cmd = "${pkgs.virt-manager}/bin/virt-manager";
        }
        # ) ++ (
        # TODO: re-introduce when adding Steam
        # lib.optional config.my.gaming.steam.enable {
        #   shortcut = "s";
        #   label = "[s]team";
        #   cmd = "my-steam";
        # }
      );
    }
  ]; # customModes

  # Helper functions to transform `customModes` into Sway-compatible
  # keybindings and modes

  # Construct the binding mode name that is also displayed in the bar
  # Make a sorted list of the labels of `entries`
  makeModeName = { prefix, entries, ... }:
    let
      filter = s: builtins.replaceStrings [ "[" "]" ] [ "" "" ] s;
      cmp = x: y: (filter x.label) < (filter y.label);
      sortedEntries = builtins.sort cmp entries;
    in
    "${prefix}: " + (
      builtins.concatStringsSep
        ", "
        (map (builtins.getAttr "label") sortedEntries)
    );

  # Construct a mode with the shortcuts taken from `entries` and return a pair
  # that is convertible to HM `config.wayland.windowManager.sway.config.modes`
  makeMode = args @ { shortcut, prefix, entries }:
    let
      md = "mode default";
      execMd = cmd: "exec --no-startup-id ${cmd}, ${md}";
    in
    lib.nameValuePair "${makeModeName args}" (
      (
        builtins.listToAttrs (
          map (e: lib.nameValuePair e.shortcut (execMd e.cmd)) entries
        )
      ) // {
        # Allow exiting from the mode using either Enter or Escape or the mode
        # shortcut itself
        Return = md;
        Escape = md;
        "${shortcut}" = md;
      }
    );

  # Return a mode keybinding for `shortcut` based `entries`; a pair
  # that is convertible to HM
  # `config.wayland.windowManager.sway.config.keybindings`
  makeModeKeybinding = args @ { shortcut, prefix, entries, ... }:
    lib.nameValuePair "${shortcut}" "mode \"${makeModeName args}\"";

in
{
  keybindings = builtins.listToAttrs (map makeModeKeybinding customModes);
  modes = builtins.listToAttrs (map makeMode customModes);
}
