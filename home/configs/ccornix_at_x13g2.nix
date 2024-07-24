{ inputs, ... }:

{
  imports = [ inputs.self.homeModules.default ./ccornix.nix ];

  my = {
    desktop.enable = true;
    gaming = {
      devilutionx.enable = true;
      diablo2.enable = true;
      wine.enable = true;
    };
  };

  home.stateVersion = "24.05";

  services.kanshi.settings = [
    {
      profile = {
        name = "undocked";
        outputs = [
          { criteria = "eDP-1"; }
        ];
      };
    }
    {
      profile = {
        name = "docked";
        outputs = [
          {
            criteria = "eDP-1";
            position = "1920,0";
          }
          {
            # Use make-model-serial criterion for external monitors as the name
            # (DP-?) may change when reconnected. Get it using:
            # swaymsg -t get_outputs
            criteria = "Iiyama North America PL2493H 1211424213213";
            position = "0,0";
          }
        ];
      };
    }
  ];
}
