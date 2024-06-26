{ pkgs, ... }: {
  programs.bash.enable = true;

  home.stateVersion = "23.11";
  home.file = pkgs.lib.mkMerge [
    {
      "/home/guest/.config/neomutt/neomuttrc" = {
        text = builtins.readFile ../configs/neomutt;
      };
    }
    {
      "/home/guest/servers.sh" = {
        text = builtins.readFile ../configs/servers;
      };
    }
  ];

  programs.neomutt = {
    enable = true;
  };
}
# extraGroups = [ "wheel" ];
