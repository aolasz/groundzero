{
  description = "Personal NixOS and Home Manager configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, disko, home-manager, ... } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      lib = import ./lib inputs;
      nixosModules.default = import ./nixos/modules;
      nixosConfigurations = import ./nixos/configs inputs;
      homeModules.default = import ./home/modules;
      homeConfigurations = import ./home/configs inputs;
      devShells = import ./nixos/installer inputs;
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
      packages = self.lib.recursiveMergeAttrs [
        (forAllSystems (import ./packages inputs))
        # HACK: add HM configs as packages to be checked by `nix flake check`
        # This hack could be removed if flake-schemas became widely accepted
        # and HM supported them
        (self.lib.gatherHomeCfgActivationPkgs self.homeConfigurations)
      ];
    };
}
