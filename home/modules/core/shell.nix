{
  config,
  pkgs,
  ...
}: {
  home.sessionVariables.FLAKE0 = config.my.flakeURI;

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.cacheHome}/bash/history";
    shellAliases = {
      hm = ''home-manager --flake "$FLAKE0" -b old '';
      ls = "ls --color=auto";
      ll = "ls -lah --group-directories-first";
      lr = "ll -rt";
      grep = "grep --color=auto";
      v = "vi";
      s = "~/dev/bash-supergenpass/supergenpass.sh";
      neofetch = "fastfetch";
      # Make ipython follow terminal colors
      ipython = "ipython --colors=Linux";
    };
    # HACK: https://github.com/nix-community/home-manager/issues/2659
    initExtra = ''
      . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
    profileExtra = ''
      mkdir -p $XDG_CACHE_HOME/bash
    '';
    bashrcExtra = ''
      if [[ $(tty) != /dev/tty* ]]; then
        # alias mc='MC_SKIN=default mc'
        alias mc='MC_SKIN=julia256 mc'
        # Force mc black & white mode
        # alias mc='mc -b'/home/hapi/dev/groundzero/home/modules/core/shell.nix
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.readline = {
    enable = true;
    includeSystemConfig = true;
    variables.completion-ignore-case = "on";
  };

  home.packages = [
    pkgs.ripgrep
    (pkgs.buildFHSEnv {
      name = "pixi";
      # if you want to run it in every terminal:
      # runScript = "pixi";
      targetPkgs = pkgs: with pkgs; [pixi];
    })
  ];

  # Customize prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      command_timeout = 1000;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol = "[λ](bold red)";
      };
      directory = {
        truncation_length = 255;
        truncate_to_repo = false;
        style = "bold blue";
      };
      git_branch = {
        always_show_remote = true;
      };
      hostname = {
        format = "[$hostname]($style):";
        ssh_only = false;
        style = "bold green";
      };
      username = {
        format = "[$user]($style)@";
        show_always = true;
      };

      battery.disabled = true;
      cmd_duration.disabled = true;
      container.disabled = true;
    };
  };

  xdg.enable = true;
}
