{ inputs, ... }:

{
  imports = [ inputs.self.homeModules.default ./ccornix.nix ];

  my = {
    primaryDisplayResolution = { horizontal = 1366; vertical = 768; };

    desktop = {
      enable = true;
      theme.termFont.size = 12;
    };
    gaming = {
      devilutionx.enable = true;
    };
  };

  home.stateVersion = "23.11";
}
