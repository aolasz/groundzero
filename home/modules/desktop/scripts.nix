{ pkgs, ... }:

{
  my-brightness = pkgs.writeShellApplication {
    name = "my-brightness";
    text = builtins.readFile ../../.local/bin/my-brightness;
    runtimeInputs = with pkgs; [ brightnessctl gawk ];
  };

  my-color-picker = pkgs.writeShellApplication {
    name = "my-color-picker";
    text = builtins.readFile ../../.local/bin/my-color-picker;
    runtimeInputs = with pkgs; [ grim imagemagick slurp ];
  };

  my-import-gsettings = pkgs.writeShellApplication {
    name = "my-import-gsettings";
    text = builtins.readFile ../../.local/bin/my-import-gsettings;
    runtimeInputs = with pkgs; [ glib ];
  };

  my-volume = pkgs.writeShellApplication {
    name = "my-volume";
    text = builtins.readFile ../../.local/bin/my-volume;
    runtimeInputs = [ pkgs.pamixer ];
  };
  my-mtp = pkgs.writeShellApplication {
    name = "my-mtp";
    text = builtins.readFile ../../.local/bin/my-mtp;
    runtimeInputs = [ pkgs.glib pkgs.gvfs ];
  };

}
