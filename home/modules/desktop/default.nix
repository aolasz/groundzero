{ config, lib, ... }:

let
  cfg = config.my.desktop;
in
{
  imports = [
    ./bemenu.nix
    ./foot.nix
    ./generic.nix
    ./i3status-rust.nix
    ./imv.nix
    ./inkscape.nix
    ./libreoffice.nix
    ./mako.nix
    ./mpv.nix
    ./swaylock.nix
    ./swaywm.nix
    ./theme.nix
    ./zathura.nix
  ];

  options.my.desktop = with lib; {
    enable = mkEnableOption "Sway desktop";
  };

  config.my.desktop = lib.mkIf cfg.enable {
    # Required modules
    bemenu.enable = true;
    foot.enable = true;
    generic.enable = true;
    theme.enable = true;
    i3statusRust.enable = true;
    mako.enable = true;
    swaylock.enable = true;
    swaywm.enable = true;
    # Optional modules (opt-out)
    imv.enable = lib.mkDefault true;
    inkscape.enable = lib.mkDefault true;
    libreOffice.enable = lib.mkDefault true;
    mpv.enable = lib.mkDefault true;
    zathura.enable = lib.mkDefault true;
  };
}
