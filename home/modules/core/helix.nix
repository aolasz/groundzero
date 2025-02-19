{
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
    unstable.nil
    unstable.pylyzer
    unstable.pyright
    unstable.ruff
    unstable.shfmt
  ];

  # source:
  # https://github.com/helix-editor/helix/wiki/Language-Server-Configurations#ruff--pyright--pylyzer
  # performance benchmarks:
  # hx -v your_file.py 2> helix.log

  programs.helix = {
    enable = true;
    defaultEditor = true;
    package = unstable.helix;
    languages = {
      debug-adapter = {
        name = "python";
        transport = "stdio";
        command = "python";
        args = ["-m" "debugpy" "--listen" "5678" "--wait-for-client"];
        configurations.Python = {
          type = "python";
          request = "launch";
          name = "Python Debugger";
          program = "\${file}";
          pythonPath = "python";
          console = "integratedTerminal";
          cwd = "\${workspaceFolder}";
          env = {};
        };
      };
      language-server.pylyzer = {
        command = "pylyzer";
        args = ["--server"];
        config.python.settings.lint.ignore = [
          "ANN101" # Disable attribute checks for dynamically loaded classes
          "E501" # Ignore line length errors
        ];
      };
      language-server.pyright = {
        # command = "pyright-langserver";
        # args = ["--stdio"];
        config.python.analysis = {
          autoSearchPaths = true;
          functionReturnTypes = true;
          typeCheckingMode = "strict";
          useLibraryCodeForTypes = true;
          variableTypes = true;
        };
        config.python.settings.lint.ignore = [
          "ANN101" # Disable attribute checks for dynamically loaded classes
          "E501" # Ignore line length errors
        ];
      };
      language-server.ruff = {
        command = "ruff";
        args = ["server"];
        config.python.settings = {
          lineLength = 98;
          lint = {
            select = [
              "E" # pycodestyle errors
              "F" # Pyflakes
              # "I" # isort
              "C" # complexity
              "B" # Bugbear
              "S" # security
              # "ANN" # type annotations
              # "N" # naming
              # "D" # docstrings
            ];
            ignore = [
              "ANN101" # Disable attribute checks for dynamically loaded classes
              "E501" # Ignore line length errors
            ];
            extend-select = ["W"]; # Add warnings
          };
          format.preview = true; # Enable experimental formatting rules
          target-version = "py313";
          per-file-ignores = {
            "__init__.py" = ["F401"]; # Ignore unused imports in __init__.py files
          };
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
          language-servers = [
            {
              name = "pyrigth";
              except-features = ["format" "diagnostics"];
            }
            {
              name = "ruff";
              only-features = ["format" "diagnostics"];
            }
            "pylyzer"
          ];
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
        idle-timeout = 500; # Milliseconds
        indent-guides = {
          render = true;
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
        "A-f" = ":format";
        "A-w" = ":buffer-close";
        "A-x" = "extend_to_line_bounds";
        "A-," = "goto_previous_buffer";
        "A-." = "goto_next_buffer";
        "A-/" = "repeat_last_motion";
        "C-c" = ":lsp-restart";
        "D" = "kill_to_line_end";
        "X" = "select_line_above";
      };
      keys.select = {
        A-x = "extend_to_line_bounds";
        X = "select_line_above";
      };
      theme = "gruvbox";
    };
  };
}
