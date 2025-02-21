{
  config,
  pkgs,
  unstable,
  ...
}: {
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.packages = [
    unstable.alejandra
    unstable.bash-language-server
    unstable.helix
    unstable.nil
    pkgs.basedpyright
    unstable.ruff
    unstable.shfmt
  ];

  xdg.configFile."helix/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink ./config.toml;

  xdg.configFile."helix/languages.toml".source =
    config.lib.file.mkOutOfStoreSymlink ./languages.toml;

  # source:
  # https://github.com/helix-editor/helix/wiki/Language-Server-Configurations#pyright--ruff
  # performance benchmarks:
  # hx -v your_file.py 2> helix.log
}
