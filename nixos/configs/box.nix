# X570 Taichi
# Resolution: 2160x1440
# CPU: AMD Ryzen 7 5800X (16) @ 3.80 GHz
# GPU: NVIDIA GeForce GTX 1080 Ti [Discrete]
# Memory: 31.27 GiB ECC
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.disko.nixosModules.disko
    inputs.self.nixosModules.default
    ./user.nix
  ];

  my = {
    desktop = {
      enable = true;
      virtCamera.enable = true;
      #brotherMfp.enable = true;
    };
    gaming.steam.enable = true;
    network = {
      interfaces = {
        wired = {wired0 = "a8:a1:59:6a:c5:5d";};
        wireless = {wireless0 = "b0:a4:60:34:6f:43";};
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
        "ahci"
        "k10temp"
        "nvme"
        #"rtsx_pci_sdmmc"
        "sd_mod"
        #"sdhci_pci"
        #"thunderbolt"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      # kernelModules = [ "nvidia" ];
    };
    blacklistedKernelModules = ["nouveau"];
    kernelModules = [
      "kvm-amd"
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];
    kernelParams = [
      "nvidia_drm.fbdev=1"
      "nvidia-drm.modeset=1"
    ];
    #extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
    loader.systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
  };

  # neededForBoot flag is not settable from disko
  fileSystems = {
    "/var/log".neededForBoot = true;
    "/persist".neededForBoot = true;
  };

  swapDevices = [];

  hardware = {
    cpu.amd.updateMicrocode =
      lib.mkDefault
      config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true; # Critical for 32-bit Vulkan support
      extraPackages = with pkgs; [
        libva
        libvdpau-va-gl
        # nvidia-vaapi-driver
        vaapiVdpau
        vulkan-extension-layer # Add explicit ICD packages
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva
        vulkan-loader
        vulkan-validation-layers
        vulkan-tools
      ];
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      forceFullCompositionPipeline = true;
      nvidiaPersistenced = true;
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/nvidia-x11/default.nix
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    }; # nvidia
  }; # hardware

  networking.hostName = "box";

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver = {
    videoDrivers = ["nvidia"];
  };

  services.greetd.enable = false;

  services.getty.autologinUser = "hapi";

  nixpkgs.hostPlatform = "x86_64-linux";

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  system.activationScripts.vulkan-links = ''
    mkdir -p /usr/lib
    mkdir -p /usr/lib32
    ln -sfn /run/opengl-driver/lib/libvulkan.so.1 /usr/lib/libvulkan.so.1
    ln -sfn /run/opengl-driver/lib/libvulkan.so.1 /usr/lib32/libvulkan.so.1
    ln -sfn ${pkgs.vulkan-loader}/lib/libvulkan.so.1 /usr/lib/libvulkan.so.1
    ln -sfn ${pkgs.pkgsi686Linux.vulkan-loader}/lib/libvulkan.so.1 /usr/lib32/libvulkan.so.1
  '';

  system.stateVersion = "24.05";

  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_512GB_S42YNF0M711223M";
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
                mountOptions = ["umask=0077"];
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
      nvme1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_1TB_S462NF0M606657T";
        content = {
          type = "gpt";
          partitions = {
            nvme1n1p1 = {
              name = "nvme1";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/nvme1";
              };
            };
          }; # partitions
        }; # content
      }; # nvme1
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
