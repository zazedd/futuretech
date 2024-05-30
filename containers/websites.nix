# 3 websites are going to be defined here using nginx
# 2 only accessible the intranet: admin.futuretech.pt and gestao.futuretech.pt
# 1 accessible from outside and in: clientes.futuretech.pt

# email server also
{ pkgs, options, config, home-manager, ... }:
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
        openFirewall = true;
        tls = {
          loader = "file";
          certificates = [{
            keyPath = "/var/lib/acme/mx1.futuretech.pt/key.pem";
            certPath = "/var/lib/acme/mx1.futuretech.pt/cert.pem";
          }];
        };

        # Enable TLS listeners. Configuring this via the module is not yet
        # implemented, see https://github.com/NixOS/nixpkgs/pull/153372
        config = builtins.replaceStrings [
          "imap tcp://0.0.0.0:143"
          "submission tcp://0.0.0.0:587"
        ] [
          "imap tls://0.0.0.0:993 tcp://0.0.0.0:143"
          "submission tls://0.0.0.0:465 tcp://0.0.0.0:587"
        ]
          options.services.maddy.config.default;

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
          # locations."/".extraConfig = ''
          #   allow 10.0.0.0/16;
          #   deny all; # Deny all other IPs
          # '';
        };

        virtualHosts."gestao.futuretech.pt" = {
          addSSL = true;
          enableACME = true;
          root = "/etc/www/gestao";
          # locations."/".extraConfig = ''
          #   allow 10.0.0.0/16;
          #   deny all; # Deny all other IPs
          # '';
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "foo@bar.com";
        certs = {
          "mx1.futuretech.pt" = {
            group = config.services.maddy.group;
            webroot = "/var/lib/acme/acme-challenge/";
          };
        };
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 53 80 443 465 993 ];
          allowedUDPPorts = [ 53 80 443 465 993 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      services.resolved.enable = true;

      system.stateVersion = "24.05";
    };
  };
}
