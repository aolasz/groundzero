{ inputs, config, pkgs, ... }:

let
  inherit (inputs) self;
in
{
  users.users.hapi = {
    isNormalUser = true;
    uid = 1000;
    hashedPasswordFile = "/persist/secrets/user-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5QnI50amnfCPNoW2YWZoUbzQBNgplTsfy4jgVr2RJG l15"
    ];
    shell = pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      "dialout" # to access serial ports
    ] ++ self.lib.filterExistingGroups config [
      "networkmanager"
      "scanner"
      "lp"
      "libvirtd"
    ];
  };
}
