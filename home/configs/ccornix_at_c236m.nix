{ inputs, ... }:

{
  imports = [ inputs.self.homeModules.default ./ccornix.nix ];

  my = {
    primaryDisplayResolution = { horizontal = 1680; vertical = 1050; };

    desktop = {
      enable = true;
      theme.termFont.size = 10;
    };
    virtualization.enable = true;
  };

  home.stateVersion = "23.11";
}
