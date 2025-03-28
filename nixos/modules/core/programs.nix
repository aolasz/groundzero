{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    bashmount
    coreutils
    fuse
    libressl
    mc
    # (inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.python313.withPackages (ps:
    #   with ps; [
    #     debugpy
    #   ]))
    rsync
    uv
    wget

    # Diagnostics
    dmidecode # for reading HW information (serials etc.) from the DMI table
    dnsutils # provides `nslookup`
    file # file type inspector
    hdparm # to get/set SATA device parameters
    htop # interactive process viewer
    inxi # for a quick overview of the HW and OS configuration
    iperf # for network bandwidth testing
    lm_sensors # provides `sensors` (to read temperature, fan speed etc.)
    nethogs # live per process network traffic monitoring
    pciutils # provides `lspci`
    smartmontools # for HDD S.M.A.R.T. monitoring
    stress-ng # CPU stress tester
    s-tui # Resource monitor and TUI to stress-ng
    usbutils # provides `lsusb`
  ];

  programs = {
    git.enable = true;
    mtr.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = false;
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 7";
      flake = "/home/hapi/dev/groundzero";
    };
    tmux.enable = true;
  };

  # Needed for `gio mount`
  services.gvfs.enable = true;
  # Needed for bashmount and CLI udisksctl
  services.udisks2.enable = true;
  security.polkit.enable = true;
}
