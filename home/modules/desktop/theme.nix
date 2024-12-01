# Desktop theme settings

{ config, pkgs, lib, ... }:

let
  cfg = config.my.desktop.theme;

  getGtkPkg = mod:
    let
      pkg = (builtins.getAttr mod config.gtk).package;
    in
    lib.optional (pkg != null) pkg;

  backgroundPkg = let
      inherit (config.colorScheme.palette) base00 base01 base02 base03;
      width = config.my.primaryDisplayResolution.horizontal;
    in pkgs.stdenvNoCC.mkDerivation {
      name = "my-background-image";
      src = ./hexagons.svg;
      dontUnpack = true;
      buildInputs = [ pkgs.librsvg ];
      buildPhase = ''
        dstdir="$out/share/backgrounds"
        mkdir -p "$dstdir"

        cat >style.css <<EOF
        .stroke { stroke:#${base00} !important; }
        .fill-0 { fill:#${base01} !important; }
        .fill-1 { fill:#${base02} !important; }
        .fill-2 { fill:#${base03} !important; }
        EOF

        rsvg-convert --keep-aspect-ratio --width=${toString width} \
          --stylesheet=style.css "$src" > "$dstdir/bg.png"
      '';
    };
in
{
  options.my.desktop.theme = {
    enable = lib.mkEnableOption "custom desktop theme";

    background = {
      path = lib.mkOption {
        type = lib.types.str;
        description = ''
          Path to the desktop background image.
        '';
        default = "${backgroundPkg}/share/backgrounds/bg.png";
      };

      scaling = lib.mkOption {
        type = lib.types.enum [ "stretch" "fit" "fill" "center" "tile" ];
        default = "tile";
      };
    }; # background

    termFont = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Iosevka Term Nerd Font";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = (
          # Not all Nerd fonts are needed
          pkgs.nerdfonts.override { fonts = [ "IosevkaTerm" ]; }
        );
      };

      style = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Regular";
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 16;
      };
    }; # termFont

    topBar = {
      fontSize = lib.mkOption {
        type = lib.types.ints.positive;
        default = cfg.termFont.size;
      };

      height = lib.mkOption {
        type = lib.types.ints.positive;
        default = cfg.topBar.fontSize + 9;
      };
    }; # topBar

    cursorTheme = {
      name = lib.mkOption {
        type = lib.types.nonEmptyStr;
        default = "Vanilla-DMZ";
      };

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.vanilla-dmz;
      };

      size = lib.mkOption {
        type = lib.types.ints.positive;
        default = 24;
      };
    };
  }; # options.my.desktop.theme

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        corefonts # MS TrueType core fonts

        cfg.termFont.package

        # gsettings-desktop-schemas

        # Needed for proper GTK and QT5 theming
        gtk-engine-murrine
        gnome-themes-extra
        libsForQt5.qtstyleplugins
      ];

      sessionVariables = {
        # Add all theme directories to XDG_DATA_DIRS
        XDG_DATA_DIRS = (
          (
            builtins.foldl' (s: p: s + "${p.out}/share:") "" (
              (getGtkPkg "theme")
              ++ (getGtkPkg "iconTheme")
              ++ (getGtkPkg "cursorTheme")
            )
          ) + "$XDG_DATA_DIRS"
        );
        # SVG loader for pixbuf (needed for GTK svg icon themes)
        GDK_PIXBUF_MODULE_FILE =
          "${pkgs.librsvg.out}/lib/gdk-pixbuf-2.0/*/loaders.cache";
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
        # QT_FONT_DPI = 128;
      }; # sessionVariables
    }; # home

    gtk = {
      enable = true;
      theme = {
        # TODO: Mint-Y theme seems more polished than the auto-generated one.
        # name = config.colorScheme.slug;
        # package = nix-colors-lib.gtkThemeFromScheme {
        #   scheme = config.colorScheme;
        # };
        name = "Mint-Y-Dark-Grey";
        package = pkgs.mint-themes;
      };
      font = {
        name = "DejaVu Sans";
        package = pkgs.dejavu_fonts;
        size = cfg.termFont.size;
      };
      iconTheme = {
        name = "Mint-Y-Grey";
        package = pkgs.mint-y-icons;
      };
      inherit (cfg) cursorTheme;
      gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      gtk3.bookmarks = [ ];
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };

    fonts.fontconfig.enable = true;

    xdg.enable = true;
  }; # config
}
