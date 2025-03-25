{
  config,
  lib,
  ...
}: {
  home = {
    username = "hapi";
    homeDirectory = "/home/hapi";

    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };
    file.".ssh/allowed_signers".text = ''
      * ${builtins.readFile "/home/hapi/.ssh/id_ed25519.pub"}
    '';
  };

  programs.git = {
    userName = "aolasz";
    userEmail = "49680062+aolasz@users.noreply.github.com";
    aliases = {
      a = "add";
      c = "commit";
      ca = "commit --amend";
      can = "commit --amend --no-edit";
      cl = "clone";
      cm = "commit -m";
      co = "checkout";
      cp = "cherry-pick";
      cpx = "cherry-pick -x";
      d = "diff";
      f = "fetch";
      fo = "fetch origin";
      fu = "fetch upstream";
      lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
      lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
      pl = "pull";
      pr = "pull -r";
      ps = "push";
      psf = "push -f";
      rb = "rebase";
      rbi = "rebase -i";
      r = "remote";
      ra = "remote add";
      rr = "remote rm";
      rv = "remote -v";
      rs = "remote show";
      st = "status";
    };
  };

  my.flakeURI = "${config.home.homeDirectory}/dev/groundzero";
}
