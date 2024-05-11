# 3 websites are going to be defined here using nginx
# 2 only accessible the intranet: admin.futuretech.pt and gestao.futuretech.pt
# 1 accessible from outside and in: clientes.futuretech.pt
{ pkgs, ... }: {
  containers.websites = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "192.168.100.5/24";
    config = {
      services.nginx.enable = true;
      services.nginx.virtualHosts."admin.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/var/www/admin";
      };

      services.nginx.virtualHosts."gestao.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/var/www/gestao";
      };

      services.nginx.virtualHosts."clientes.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/var/www/gestao";
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "foo@bar.com";
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 80 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      services.resolved.enable = true;
    };
  };
}
