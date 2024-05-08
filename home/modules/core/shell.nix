{ config, ... }:

{
  home.sessionVariables.FLAKE0 = config.my.flakeURI;

  programs.bash = {
    enable = true;
    historyFile = "${config.xdg.cacheHome}/bash/history";
    shellAliases = {
      hm = ''home-manager --flake "$FLAKE0" -b old '';
      ls = "ls --color=auto";
      ll = "ls -lah --group-directories-first";
      grep = "grep --color=auto";
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
        # alias mc='mc -b'
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

  # Customize prompt
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      command_timeout = 1000;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
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
