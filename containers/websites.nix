# 3 websites are going to be defined here using nginx
# 2 only accessible the intranet: admin.futuretech.pt and gestao.futuretech.pt
# 1 accessible from outside and in: clientes.futuretech.pt

# email server also
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
      services.getty.autologinUser = "root";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "";
      };

      security.sudo.wheelNeedsPassword = false;
      users.users.root.hashedPassword = "";


      # email server
      services.maddy = {
        enable = true;
        primaryDomain = "futuretech.pt";
        ensureAccounts = [
          "user1@futuretech.pt"
          "user2@futuretech.pt"
          "postmaster@futuretech.pt"
        ];
        ensureCredentials = {
          # This will make passwords world-readable in the Nix store
          "user1@futuretech.pt".passwordFile = "${pkgs.writeText "postmaster" "test"}";
          "user2@futuretech.pt".passwordFile = "${pkgs.writeText "postmaster" "test"}";
          "postmaster@futuretech.pt".passwordFile = "${pkgs.writeText "postmaster" "test"}";
        };
      };

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
          allowedTCPPorts = [ 25 53 80 143 443 465 587 993 ];
          allowedUDPPorts = [ 25 53 80 143 443 465 587 993 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "24.05";
    };
  };
}
