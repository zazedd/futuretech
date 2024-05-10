({ pkgs, ... }: {
  services.getty.autologinUser = "guest";
  users.users."guest" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "123";
  };

  security.sudo.wheelNeedsPassword = false;

  # Network configuration.
  networking = {
    bridges.br0.interfaces = [ "eth0" ]; # Adjust interface accordingly

    useDHCP = false;
    interfaces."br0".useDHCP = true;

    interfaces."br0".ipv4.addresses = [{
      address = "192.168.100.3";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.100.1";
    nameservers = [ "192.168.100.1" ];
  };

  system.stateVersion = "24.05";
})
