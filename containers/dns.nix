# DNS for the whole network
{ pkgs, ... }: {
  containers.dns = {
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
      security.acme.acceptTerms = true;
      security.acme.defaults.email = "security@example.com";

      # dns server
      services.nsd = {
        enable = true;

        rootServer = true;
        interfaces = pkgs.lib.mkForce [ ];

        keys."tsig.futuretech.pt." = {
          algorithm = "hmac-sha256";
          keyFile = pkgs.writeTextFile { name = "tsig.futuretech.pt."; text = "aR3FJA92+bxRSyosadsJ8Aeeav5TngQW/H/EF9veXbc="; };
        };

        zones."futuretech.pt.".data =
          let
            # Careful: this needs to be changed according to what your maddy generated.
            # The key is in the /var/lib/maddy/dkim_keys directory
            domainkey = ''
              v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyDsD90wH8v32SEQDR6WBi/Vx0vPZWnOdZMnj1tnntVvZPXcAT01wIWfp8tj81f5QqdV1/I8/1/QDrsIaZusJTfv3+FycHng3v7NTX7kWNZMJoYPL4nM9F7jn5hl1xeZyzKWj9OF2zIKekRzQZ2I9sA3aAe749n+lq9rdImB12qFG7/u1bXKKjJOkqhKhhUM6CLKrpezAV7Lz5L1L61ltP9v7bVZWtyFvkKk5pmFqDA7D45cFIp1R5zo9AflQFVHoHhWdqTJ9jtsNkLDChx3CqQzrTENT2l4uImeHS2i/5lxvukoAsOw+L1rkNFJhkiPL//jb8v4FnA7QGch0s3QohQIDAQAB'';
            segments = ((pkgs.lib.stringLength domainkey) / 255);
            domainkeySplitted = map (x: pkgs.lib.substring (x * 255) 255 domainkey) (pkgs.lib.range 0 segments);
          in
          ''
            @ SOA ns.futuretech.pt. noc.futuretech.pt. 666 7200 3600 1209600 3600
            @ NS ns.futuretech.pt.
            @ MX 10 mx1
            ns                            A        10.0.0.3 
            futuretech.pt.          IN    A        10.0.0.3
            admin.futuretech.pt.    IN    CNAME    futuretech.pt.
            gestao.futuretech.pt.   IN    CNAME    futuretech.pt.
            clientes.futuretech.pt. IN    CNAME    futuretech.pt.

            mx1                           A        10.0.0.3
            @                             TXT      "v=spf1 mx ~all"
            mx1                           TXT      "v=spf1 mx ~all"
            _dmarc                        TXT      "v=DMARC1; p=quarantine; ruf=mailto:postmaster@futuretech.pt
            _mta-sts                      TXT      "v=STSv1; id=1"
            _smtp._tls                    TXT      "v=TLSRPTv1;rua=mailto:postmaster@futuretech.pt"
            default._domainkey            TXT      "${pkgs.lib.concatStringsSep "\" \"" domainkeySplitted}"
          '';

        zones."0.0.10.in-addr.arpa.".data = ''
          @ SOA ns.futuretech.pt. noc.futuretech.pt. 666 7200 3600 1209600 3600
          @ NS ns.futuretech.pt.
          3.0.0.10.in-addr.arpa.  IN    PTR      mx1.futuretech.pt.
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
