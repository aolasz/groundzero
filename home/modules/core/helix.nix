{ unstable, ... }:
{
  programs.helix = {
    enable = true;
    package = unstable.helix;
  };
}

