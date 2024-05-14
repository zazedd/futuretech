# 3 websites are going to be defined here using nginx
# 2 only accessible the intranet: admin.futuretech.pt and gestao.futuretech.pt
# 1 accessible from outside and in: clientes.futuretech.pt
{ pkgs, ... }:
let
  simple_page = str: '' 
            <html lang="en">
            <body>
                <h1>${str}</h1>
            </body>
            </html>
'';
in
{
  containers.websites = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "10.0.0.3/24";
    config = {
      services.getty.autologinUser = "guest";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      security.sudo.wheelNeedsPassword = false;

      environment.etc = {
        "/www/admin/index.html" = {
          enable = true;
          text = simple_page "Admin";
        };

        "/www/gestao/index.html" = {
          enable = true;
          text = simple_page "Gestão";
        };

        "/www/clientes/index.html" = {
          enable = true;
          text = simple_page "Clientes";
        };
      };

      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;

        virtualHosts."clientes.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/etc/www/clientes";
        };

        virtualHosts."admin.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/etc/www/admin";
          locations."/".extraConfig = ''
            allow 10.0.0.0/16;
            deny all; # Deny all other IPs
          '';
        };

        virtualHosts."gestao.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/etc/www/gestao";
          locations."/".extraConfig = ''
            allow 10.0.0.0/16;
            deny all; # Deny all other IPs
          '';
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "foo@bar.com";
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 443 ];
          allowedUDPPorts = [ 443 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "24.05";
    };
  };
}
