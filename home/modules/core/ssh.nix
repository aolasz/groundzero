{ lib, ... }:
{
  home.file.".ssh/config.d/.keep".text = "";

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
        serverAliveInterval = 0; # Set to non-zero if you want keepalive
        serverAliveCountMax = 3;
        compression = false;
        identitiesOnly = false; # Set to true for better security
        checkHostIP = true;
      };
      includes = [ "~/.ssh/config.d/*" ];
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    keychain = {
      enable = true;
      keys = lib.mkDefault [ "id_ed25519" ];
    };
  };
}
