{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  security.sudo.extraConfig = ''
    # Rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  # Exclude root file system from bashmount due to the large number of
  # persistence-related bind mounts
  environment.etc."bashmount.conf" = {
    text = ''
      exclude=( 'LABEL="root"' )
    '';
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        directory = "/etc/NetworkManager/system-connections";
        mode = "u=rwx,g=,o=";
      }
      "/etc/ssh/authorized_keys.d"
      "/var/lib/alsa"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/upower"
      { directory = "/var/lib/bluetooth"; mode = "u=rwx,g=,o="; }
      { directory = "/var/lib/fail2ban"; mode = "u=rwx,g=rx,o="; }
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
    ];
  };
}
