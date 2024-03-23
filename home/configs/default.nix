{ self, nixpkgs, home-manager, ... } @ inputs:

let
  inherit (nixpkgs) lib;

  inventory = (
    lib.mapAttrsToList
    (host: config: { user = "ccornix"; inherit host; inherit (config) pkgs; })
    self.nixosConfigurations
  ) ++ [
    # {
    #   user = "ccornix";
    #   host = "unmanaged";
    #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
    # }
  ];

  mkHomeConfig = { user, host, pkgs }: lib.nameValuePair "${user}@${host}" (
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./${user}_at_${host}.nix ];
    }
  );
in
  self.lib.mapListToAttrs mkHomeConfig inventory
