{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.my.network.shares;

  options = [
    "x-systemd.automount"
    "x-systemd.idle-timeout=120"
    "x-systemd.mount-timeout=5"
    "noauto"
    "noexec"
    "user"
    "vers=4.1"
    "noatime"
    "_netdev" # Mark as network-dependent
    #"soft"                         # Return error instead of hanging indefinitely
    "hard" # Keep hard mount for data integrity
    "intr" # Allow interrupts (Ctrl+C to abort)
    "timeo=40" # Timeout per retry: 5 seconds (in deciseconds)
    "retrans=3" # Retry 3 times before failing
  ];

  mountCommands = [
    "mount.nfs4"
    "umount.nfs4"
  ];

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
        # device = "nas:/mnt/hdd_pool/data/obsidian";
        device = "192.168.31.159:/mnt/hdd_pool/data/obsidian";
        fsType = "nfs";
        options = options ++ [ "rw" ];
      };
      "/nfs/nas/media" = {
        # device = "nas:/mnt/hdd_pool/data/media";
        device = "192.168.31.159:/mnt/hdd_pool/data/media";
        fsType = "nfs";
        options = options ++ [ "rw" ];
      };
    };

    environment.systemPackages = [ pkgs.nfs-utils ];

    # Disable rpcbind, not needed for NFSv4
    services.rpcbind.enable = lib.mkForce false;

    security = { inherit wrappers; };
  };
}
