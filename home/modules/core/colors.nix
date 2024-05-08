{ inputs, config, ... }:

let
  inherit (inputs) nix-colors;
in
{
  imports = [ nix-colors.homeManagerModule ];

  colorscheme = nix-colors.colorSchemes.decaf;

  programs.dircolors.enable = true;

  home.sessionVariables = {
    NEWT_COLORS_FILE = "${config.xdg.configHome}/newt/colors";
    MY_BASE16_COLORSCHEME = config.colorScheme.slug;
  };

  xdg = {
    enable = true;
    # For more information on customizing Newt colors, see docs/newt.md
    configFile."newt/colors".text = ''
      root=
      roottext=
      helpline=
      border=
      window=
      shadow=
      title=
      button=white,
      actbutton=
      compactbutton=
      checkbox=
      actcheckbox=white,red
      entry=white,black
      disentry=white,gray
      label=black,
      listbox=
      actlistbox=black,
      sellistbox=
      actsellistbox=white,red
      textbox=
      acttextbox=
      emptyscale=
      fullscale=
    '';
  };
}
