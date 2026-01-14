{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [
    pkgs.gitlint
  ];

  # https://jeppesen.io/git-commit-sign-nix-home-manager-ssh/

  programs.git = {
    enable = true;
    settings = {
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = false;
      };
      user.signingkey = "~/.ssh/id_ed25519.pub";
    };
  };
}
