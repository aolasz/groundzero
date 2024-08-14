{ pkgs, config, ... }:

{
  programs.fastfetch.enable = true;

  home.packages = [
    pkgs.htop
    #pkgs.neofetch
    pkgs.unzip
  ];
}
