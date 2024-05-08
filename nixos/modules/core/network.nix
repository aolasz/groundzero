{ config, ... }:

{
  networking = {
    useDHCP = false;
    networkmanager = {
      enable = true;
      wifi.scanRandMacAddress = false;
    };
    firewall.enable = true;

    # Generate the hostId from the hostname
    hostId = builtins.substring 0 8 (
      builtins.hashString "sha256" config.networking.hostName
    );
  };
}
