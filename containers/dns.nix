# DNS for the whole network
{ pkgs, ... }: {
  containers.dns = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "10.0.0.2/24";
    config = {
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      services.getty.autologinUser = "guest";

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
                v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwyFhwQd0ThJvwByta60iyTSMpBKe02EiVoU69A8OXYy+sQW6hsLEYb/CxBTMiyqIFhkJsdP8VsJCi0Goxpmq0GS1WxHKwxEC0m+GNgy7yMzHorrbPHC2YiIO9qGUZHdk9Ht4FUXQLlfrCQuxtDkUNoE6o9jqRAO9XiOzlUF2tpGRBR5UT0Q0nPV8lW+M8AlK+lfFNkF7OtfMyT+KeOBVLPW9v8163bQDF47fD8Udxw3KwxLJu3sprz8wgXz0i9PhoJwgSq9TEM3FoigKVYC0DubJw5jpJIK+olefNtWdcZg614S0qQHSl1f0rUbqbBvPOtt408NYFl4K3U3d0TDtEwIDAQAB
            '';
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

        # Reverse DNS lookup. important for email
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
