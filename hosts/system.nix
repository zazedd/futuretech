({ pkgs, home-manager, ... }: {
  services.getty.autologinUser = "guest";
  users.users."guest" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "123";
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    dig
    vim
    inetutils
    openssl
    gsasl
    gnutls
  ];

  # Network configuration.
  networking = {
    # allow containers to use external network
    # nat.enable = true;
    # nat.internalInterfaces = ["ve-+"];
    # nat.externalInterface = "eth0";

    bridges.br0.interfaces = [ "eth0" ];

    useDHCP = false;
    interfaces."br0".useDHCP = true;

    interfaces."br0".ipv4 = {
      addresses = [
        {
          address = "10.0.0.0";
          prefixLength = 24;
        }
        {
          address = "82.103.20.1";
          prefixLength = 24;
        }
      ];
      routes = [
        {
          address = "82.103.20.0";
          prefixLength = 24;
          via = "10.0.0.1";
        }
        {
          address = "10.0.0.0";
          prefixLength = 24;
          via = "82.103.20.2";
        }
      ];
    };

    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.0.2" ];
    extraHosts = "";
  };

  system.stateVersion = "24.05";
})
