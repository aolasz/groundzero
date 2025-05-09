{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.zfs;

  rootDiffScript = pkgs.writeShellScriptBin "my-root-diff" ''
    sudo ${pkgs.zfs}/bin/zfs diff rpool/local/root@blank
  '';
  xanmodKernel = pkgs.linuxPackages_xanmod;
in {
  options.my.zfs = {
    enable = lib.mkEnableOption "custom ZFS configuration and services";
    arcMaxMiB = lib.mkOption {
      type = lib.types.int;
      default = 1024;
      description = ''
        Maximal size of the ZFS ARC cache. Zero means dynamically managed by
        ZFS.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.postDeviceCommands = lib.mkAfter ''
      zfs rollback -r rpool/local/root@blank
    '';

    boot = {
      kernelParams =
        [
          "nohibernate"
          # WORKAROUND: get rid of error
          # https://github.com/NixOS/nixpkgs/issues/35681
          "systemd.gpt_auto=0"
        ]
        ++ lib.optional (cfg.arcMaxMiB > 0)
        "zfs.zfs_arc_max=${toString (cfg.arcMaxMiB * 1048576)}";

      kernelPackages = xanmodKernel;

      supportedFilesystems.zfs = lib.mkForce true;
    };

    environment = {
      persistence."/persist".files = ["/etc/zfs/zpool.cache"];
      systemPackages = [rootDiffScript];
    };

    services.zfs = {
      trim.enable = true;
      autoScrub = {
        enable = true;
        pools = ["rpool"];
      };
    };

    systemd.services.zfs-mount.enable = false;
  };
}
