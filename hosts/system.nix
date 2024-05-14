({ pkgs, ... }: {
  services.getty.autologinUser = "guest";
  users.users."guest" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "123";
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = [
    pkgs.dig
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

    interfaces."br0".ipv4.addresses = [
      {
        address = "10.0.0.1";
        prefixLength = 24;
      }
    ];

    defaultGateway = "10.0.0.1";
    nameservers = [ "10.0.0.2" ];

    extraHosts = "81.104.20.2 futuretech.pt";
  };

  system.stateVersion = "24.05";
})
