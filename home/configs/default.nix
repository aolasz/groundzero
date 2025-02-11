{ self, nixpkgs, nixpkgs-unstable, home-manager, ... } @ inputs:

let
  inherit (nixpkgs) lib;

  inventory = (
    lib.mapAttrsToList
      (host: config: { user = "hapi"; inherit host; inherit (config) pkgs; })
      self.nixosConfigurations
  );
  #    ++ [
  #  {
  #    user = "hapi";
  #    host = "box";
  #    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  #  }
  #];

  mkHomeConfig = { user, host, pkgs }: lib.nameValuePair "${user}@${host}" (
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit inputs;
        unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
      modules = [ ./${user}_at_${host}.nix ];
    }
  );
in
self.lib.mapListToAttrs mkHomeConfig inventory
