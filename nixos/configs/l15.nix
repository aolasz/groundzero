# 20X300GPHV ThinkPad L15 Gen 2
# Resolution: 1920x1080
# CPU: 11th Gen Intel i5-1135G7 (8) @ 4.200GHz 
# GPU: Intel TigerLake-LP GT2 [Iris Xe Graphics] 
# Memory: 7589MiB

{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.disko.nixosModules.disko
    inputs.self.nixosModules.default
    ./user.nix
  ];

  my = {
    desktop = {
      enable = true;
      brotherMfp.enable = true;
      virtCamera.enable = true;
    };
    network = {
      interfaces = {
        # wired = { wired0 = "8c:8c:aa:86:68:9c"; };
        wireless = { wireless0 = "c8:94:02:f6:b6:37"; };
      };
      shares.enable = true;
      tailscale.enable = true;
    };
    virtualization.enable = true;
    zfs.enable = true;
  };

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "sdhci_pci"
        "thunderbolt"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "i915" ];
    };
    kernelModules = [ "kvm-intel" ];
    loader.systemd-boot.enable = true;
  };

  # neededForBoot flag is not settable from disko
  fileSystems = {
    "/var/log".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  swapDevices = [ ];

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault
      config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime ];
      extraPackages32 = with pkgs; [ intel-media-driver intel-compute-runtime ];
    };
  };

  networking.hostName = "l15";

  services.greetd.enable = false;

  services.getty.autologinUser = "hapi";

  nixpkgs.hostPlatform = "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  system.stateVersion = "23.11";

  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.8ce38e100031bdcf";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Fix world-accessible /boot/loader/random-seed
                # https://github.com/nix-community/disko/issues/527#issuecomment-1924076948
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "rpool";
              };
            };
          }; # partitions
        }; # content
      }; # system
    }; # disk
    zpool = {
      rpool = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          dnodesize = "auto";
          canmount = "off";
          xattr = "sa";
          relatime = "on";
          normalization = "formD";
          mountpoint = "none";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          compression = "lz4";
          "com.sun:auto-snapshot" = "false";
        };
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          safe = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/reserved" = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              reservation = "5GiB";
            };
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot rpool/local/root@blank
            '';
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              atime = "off";
              canmount = "on";
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "local/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "safe/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
              mountpoint = "legacy";
              "com.sun:auto-snapshot" = "true";
            };
          };
        }; # datasets
      }; # rpool
    }; # zpool
  }; # disko.devices
}
