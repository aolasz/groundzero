{ inputs, config, pkgs, lib, ... }:

{
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    package = pkgs.nixVersions.nix_2_23;
    settings = {
      auto-optimise-store = true;
      # Follow Conventional Commits style
      commit-lockfile-summary = "chore: update flake.lock";
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      # FIXME: breaks Home Manager which still uses "nix-env" instead of "nix
      # profile"
      # https://github.com/nix-community/home-manager/issues/4593
      # https://github.com/nix-community/home-manager/pull/4594
      # use-xdg-base-directories = true;
      warn-dirty = false;
    };

    # Add each flake input as a registry
    registry = lib.mapAttrs (_: v: { flake = v; }) inputs;

    # Map registries to channels (useful when using legacy commands)
    nixPath = lib.mapAttrsToList
      (n: v: "${n}=${v.to.path}")
      config.nix.registry;
  };
}
