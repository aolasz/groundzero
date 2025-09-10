{
  lib,
  stdenvNoCC,
  fontforge,
  python3,
  nerd-font-patcher,
}:
stdenvNoCC.mkDerivation {
  pname = "comic-code-nerd-font";
  version = "1.0";
  src = builtins.path {
    path = /home/hapi/.local/share/fonts/ComicCode;
    name = "comic-code-fonts";
  };

  nativeBuildInputs = [
    fontforge
    python3
    nerd-font-patcher
  ];

  buildPhase = ''
    mkdir -p patched-fonts

    declare -A styles=(
      # ComicCode variants (without ligatures)
      ["ComicCode-Regular"]="ComicCode-Regular.otf"
      ["ComicCode-Bold"]="ComicCode-Bold.otf"
      ["ComicCode-Medium"]="ComicCode-Medium.otf"
      ["ComicCode-Italic"]="ComicCode-Italic.otf"
      ["ComicCode-MediumItalic"]="ComicCode-MediumItalic.otf"
      ["ComicCode-BoldItalic"]="ComicCode-BoldItalic.otf"

      # ComicCodeLigatures variants (with ligatures)
      ["ComicCodeLigatures-Regular"]="ComicCodeLigatures-Regular.otf"
      ["ComicCodeLigatures-Bold"]="ComicCodeLigatures-Bold.otf"
      ["ComicCodeLigatures-Medium"]="ComicCodeLigatures-Medium.otf"
      ["ComicCodeLigatures-Italic"]="ComicCodeLigatures-Italic.otf"
      ["ComicCodeLigatures-MediumItalic"]="ComicCodeLigatures-MediumItalic.otf"
      ["ComicCodeLigatures-BoldItalic"]="ComicCodeLigatures-BoldItalic.otf"
    )

    echo "Starting font patching process..."

    for style in "''${!styles[@]}"; do
      font_file="$src/''${styles[$style]}"
      if [ -f "$font_file" ]; then
        echo "Patching $font_file -> $style Nerd Font..."
        nerd-font-patcher \
          --complete \
          --mono \
          --adjust-line-height \
          --progressbars \
          --outputdir patched-fonts \
          "$font_file"
        echo "Successfully patched: $style"
      else
        echo "Warning: Font file $font_file not found, skipping $style"
      fi
    done

    echo "Font patching completed. Patched files:"
    find patched-fonts -name "*.otf" -exec basename {} \;
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/opentype

    find patched-fonts -name "*.otf" -exec cp {} $out/share/fonts/opentype/ \;

    echo "Installed fonts:"
    ls -la $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "ComicCode and ComicCodeLigatures fonts patched with Nerd Fonts icons";
    longDescription = ''
      ComicCode is a monospace font designed for programming with optional ligatures.
      This package includes both the standard ComicCode and ComicCodeLigatures variants,
      all patched with Nerd Fonts icons and symbols for enhanced terminal and editor experience.

      Available styles:
      - Regular, Bold, Medium variants
      - Italic versions of all weights
      - Both ligature and non-ligature versions
    '';
    platforms = platforms.all;
    maintainers = ["aolasz"];
  };
}
