{ unstable, ... }:
{
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = unstable.helix;
    settings = {
      editor = {
        bufferline = "always"; # Enable tab bar at the top
        color-modes = true;
        cursorline = true;
        cursor-shape = {
         insert = "bar";
         normal = "block";
         select = "underline";
        };
        end-of-line-diagnostics = "hint";
        file-picker = {
          hidden = false;
          parents = false;
        };
        indent-guides = {
          render = false;
          character = "▏";
          skip-levels = 1;
        };
        inline-diagnostics.cursor-line = "error";
        line-number = "relative";
        lsp = {
          display-messages = true;
          auto-signature-help	= true;
          display-signature-help-docs	= true;
        };
        mouse = true;
        soft-wrap.enable = true;
        whitespace.render = "none";
      };
      keys.normal = {
        D = "kill_to_line_end";
        # Use Shift-l and -h to move through tabs
        S-l = ":buffer-next";
        S-h = ":buffer-previous";
      };
      theme = "gruvbox";
    };
  };
}
