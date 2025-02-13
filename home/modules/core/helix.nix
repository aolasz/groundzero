{unstable, ...}: {
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  home.packages = [
    unstable.alejandra
    unstable.bash-language-server
    unstable.nil
    unstable.ruff
    unstable.shfmt
  ];

  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = unstable.helix;
    languages = {
      language-server.ruff = {
        command = "ruff";
        config.settings = {
          lineLength = 98;
          lint.select = ["E" "F" "I"];
        };
      };
      language = [
        {
          name = "bash";
          auto-format = true;
          formatter = {
            command = "shfmt";
            args = ["-i" "2" "-ci"];
          };
          language-servers = ["bash-language-server"];
        }
        {
          name = "nix";
          language-servers = ["nil"];
          auto-format = true;
          formatter = {
            command = "alejandra";
            args = ["-q"];
          };
          indent = {
            tab-width = 2;
            unit = "  ";
          };
        }
        {
          name = "python";
          language-servers = ["ruff"];
          auto-format = true;
          formatter = {
            command = "ruff";
            args = ["format" "-"];
          };
        }
      ];
    };
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
        indent-heuristic = "tree-sitter";
        inline-diagnostics.cursor-line = "error";
        line-number = "relative";
        lsp = {
          display-messages = true;
          auto-signature-help = true;
          display-signature-help-docs = true;
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
