{ config, lib, pkgs, ... }:

let
  cfg = config.my.zfs;

  rootDiffScript = pkgs.writeShellScriptBin "my-root-diff" ''
    sudo ${pkgs.zfs}/bin/zfs diff rpool/local/root@blank
  '';

in
{
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
      kernelParams = [
        "nohibernate"
        # WORKAROUND: get rid of error
        # https://github.com/NixOS/nixpkgs/issues/35681
        "systemd.gpt_auto=0"
      ] ++ lib.optional (cfg.arcMaxMiB > 0)
        "zfs.zfs_arc_max=${toString (cfg.arcMaxMiB * 1048576)}";

      # kernel 6.11 (_stable and _latest) is unsupported(?) by ZFS so we have to fall back to 6.6
      kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
      #kernelPackages =
      #  with builtins; with lib; let
      #    latestCompatibleVersion = pkgs.linuxPackages.kernel.version;
      #    xanmodPackages = filterAttrs (name: packages: hasSuffix "_xanmod" name && (tryEval packages).success) pkgs.linuxKernel.packages;
      #    compatiblePackages = filter (packages: compareVersions packages.kernel.version latestCompatibleVersion <= 0) (attrValues xanmodPackages);
      #    orderedCompatiblePackages = sort (i: j: compareVersions i.kernel.version j.kernel.version > 0) compatiblePackages;
      #  in head orderedCompatiblePackages;

      supportedFilesystems.zfs = lib.mkForce true;
    };

    environment = {
      persistence."/persist".files = [ "/etc/zfs/zpool.cache" ];
      systemPackages = [ rootDiffScript ];
    };

    services.zfs = {
      trim.enable = true;
      autoScrub = {
        enable = true;
        pools = [ "rpool" ];
      };
    };

    systemd.services.zfs-mount.enable = false;
  };
}
