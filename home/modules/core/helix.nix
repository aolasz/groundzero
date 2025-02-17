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
        bufferline = "multiple"; # Enable tab bar at the top
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
        inline-diagnostics = {
          cursor-line = "error"; # Show inline diagnostics when the cursor is on the line
          other-lines = "disable"; # Don't expand diagnostics unless the cursor is on the line
        };
        line-number = "relative";
        lsp = {
          display-messages = true;
          auto-signature-help = true;
          display-signature-help-docs = true;
        };
        mouse = true;
        rulers = [99];
        true-color = true;
        soft-wrap.enable = true;
        statusline.left = ["mode" "spinner" "version-control" "file-name"];
        whitespace.render = "none";
      };
      keys.normal = {
        A-f = ":format";
        D = "kill_to_line_end";
        "A-," = "goto_previous_buffer";
        "A-." = "goto_next_buffer";
        A-w = ":buffer-close";
        "A-/" = "repeat_last_motion";
        A-x = "extend_to_line_bounds";
        X = "select_line_above";
      };
      keys.select = {
        A-x = "extend_to_line_bounds";
        X = "select_line_above";
      };
      theme = "gruvbox";
    };
  };
}
