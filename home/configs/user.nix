{ config, ... }:

{
  home = {
    username = "hapi";
    homeDirectory = "/home/hapi";
  };

home.file.".ssh/allowed_signers".text =
  "* ${builtins.readFile /home/hapi/.ssh/id_ed25519.pub}";

  programs.git = {
    userName = "aolasz";
    userEmail = "49680062+aolasz@users.noreply.github.com";
  };

  my.flakeURI = "${config.home.homeDirectory}/dev/groundzero";
}
