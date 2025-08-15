{ nixpkgs, home-manager, ... } @ inputs: system:

let
  pkgs = nixpkgs.legacyPackages.${system};

  isoConfig = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      ../nixos/installer/iso.nix
      { nixpkgs.hostPlatform = system; }
    ];
  };
in
{
  inherit (home-manager.packages.${system}) home-manager;
  iso = isoConfig.config.system.build.isoImage;
}
