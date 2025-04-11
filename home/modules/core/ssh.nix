{lib, ...}: {
  home.file.".ssh/config.d/.keep".text = "";

  programs = {
    ssh = {
      enable = true;
      forwardAgent = true;
      addKeysToAgent = "yes";
      includes = ["~/.ssh/config.d/*"];
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };

    keychain = {
      enable = true;
      keys = lib.mkDefault ["id_ed25519"];
    };
  };
}
