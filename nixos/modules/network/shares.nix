{ config, pkgs, lib, ... }:

let
  cfg = config.my.network.shares;

  options = [
    "x-systemd.automount"
    "x-systemd.idle-timeout=120"
    "noauto"
    "noexec"
    "user"
    "vers=4.1"
    "noatime"
  ];

  mountCommands = [ "mount.nfs4" "umount.nfs4" ];

  mkWrapper = mountCommand: {
    source = "${pkgs.nfs-utils}/bin/${mountCommand}";
    owner = "root";
    group = "root";
    setuid = true;
  };

  wrappers = lib.genAttrs mountCommands mkWrapper;

in
{
  options.my.network.shares = {
    enable = lib.mkEnableOption "access to home NAS shares";
  };

  config = lib.mkIf cfg.enable {
    # WORKAROUND: for missing sm.bak directory
    systemd.tmpfiles.rules = [ "d /var/lib/nfs/sm.bak - root root -" ];

    fileSystems = {
      "/nfs/nas/obsidian" = {
        device = "nas:/mnt/hdd_pool/data/obsidian";
        fsType = "nfs";
        options = options ++ [ "rw" ];
      };
      #"/nfs/nas/test" = {
      #  device = "nas:/mnt/hdd_pool/data/syncthing/Obsidian Volt";
      #  fsType = "nfs";
      #  options = options ++ [ "rw" ];
      #};
    };

    environment.systemPackages = [ pkgs.nfs-utils ];

    # Disable rpcbind, not needed for NFSv4
    services.rpcbind.enable = lib.mkForce false;

    security = { inherit wrappers; };
  };
}
