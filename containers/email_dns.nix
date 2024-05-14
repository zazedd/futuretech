# Email server
# DNS for the whole network
# Possibly a reverse proxy we will see
{ pkgs, ... }: {
  containers.dns-email = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "10.0.0.2/24";
    config = {

      services.getty.autologinUser = "guest";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      security.sudo.wheelNeedsPassword = false;

      # dns server
      services.nsd = {
        enable = true;

        rootServer = true;
        interfaces = pkgs.lib.mkForce [ ];

        keys."tsig.futuretech.pt." = {
          algorithm = "hmac-sha256";
          keyFile = pkgs.writeTextFile { name = "tsig.futuretech.pt."; text = "aR3FJA92+bxRSyosadsJ8Aeeav5TngQW/H/EF9veXbc="; };
        };

        zones."futuretech.pt.".data = ''
          @ SOA ns.futuretech.pt. noc.futuretech.pt. 666 7200 3600 1209600 3600
          @ NS ns.futuretech.pt.
          ns                            A        10.0.0.3 
          futuretech.pt.          IN    A        10.0.0.3
          admin.futuretech.pt.    IN    CNAME    futuretech.pt.
          gestao.futuretech.pt.   IN    CNAME    futuretech.pt.
          clientes.futuretech.pt. IN    CNAME    futuretech.pt.
        '';

        zones."futuretech.pt.".provideXFR = [ "0.0.0.0 tsig.futuretech.pt." ];
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      system.stateVersion = "24.05";
    };
  };
}
