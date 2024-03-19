{ inputs, config, pkgs, ... }:

let
  inherit (inputs) self;
in
{
  users.users.ccornix = {
    isNormalUser = true;
    uid = 1000;
    hashedPasswordFile = "/persist/secrets/ccornix-password";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPbbRvx53TLy1P9jnOR1PxmxMUHHsP/hfLuuZHE511G ccornix@parsley"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwOoWSaUdhv7WlmcM4GfL2Cytga0YHJ+SDIF3l4bUoF ccornix@sage"
      # FIXME: rosemary
      # FIMXE: thyme
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGrn6fyywNrzVF2JkgO37INLGuW5K9LmmXKlGK/5R7Rz ccornix@garlic"
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
