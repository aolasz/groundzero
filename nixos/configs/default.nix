{ self, nixpkgs, ... } @ inputs:

let
  hosts = [
    # "b550"
    # "c236m"
    # "hypervvm"
    "l15"
    # "x13"
    # "x13g2"
    # "x230"
  ];

  mkNixosConfig = host: nixpkgs.lib.nameValuePair host (
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./${host}.nix ];
    }
  );
in
self.lib.mapListToAttrs mkNixosConfig hosts
