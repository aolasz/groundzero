{
  config,
  pkgs,
  unstable,
  ...
}: let
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.packages = [
    unstable.bash-language-server
    unstable.helix
    unstable.nil
    unstable.nixfmt
    pkgs.basedpyright
    unstable.ruff
    unstable.shfmt
  ];

  xdg.configFile."helix/config.toml".source =
    link "${config.my.flakeURI}/home/.config/helix/config.toml";

  xdg.configFile."helix/languages.toml".source =
    link "${config.my.flakeURI}/home/.config/helix/languages.toml";

  # source:
  # https://github.com/helix-editor/helix/wiki/Language-Server-Configurations#pyright--ruff
  # performance benchmarks:
  # hx -v your_file.py 2> helix.log
}
