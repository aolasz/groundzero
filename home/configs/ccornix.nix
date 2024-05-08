{ config, ... }:

{
  home = {
    username = "ccornix";
    homeDirectory = "/home/ccornix";
  };

  programs.git = {
    userName = "ccornix";
    userEmail = "ccornix1758@gmail.com";
  };

  my.flakeURI = "${config.home.homeDirectory}/devel/groundzero";
}
