{ pkgs, ... }:
{
  containers.proxy = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "82.103.20.2/24";
    bindMounts = {
      # monta o /etc/resolv.conf do host, para partilhar os nameservers
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };
    extraVeths = {
      "eth1" = {
        localAddress = "10.0.0.5/24";
        hostBridge = "br0";
      };
    };
    config = {
      services.getty.autologinUser = "guest";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      environment.systemPackages = [
        pkgs.dig
      ];

      security.sudo.wheelNeedsPassword = false;

      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedProxySettings = true;

        virtualHosts."clientes.futuretech.pt" = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "https://clientes.futuretech.pt";
        };

        virtualHosts."admin.futuretech.pt" = {
          enableACME = true;
          forceSSL = true;
          locations."/".return = 403; # Forbidden
        };

        virtualHosts."gestao.futuretech.pt" = {
          enableACME = true;
          forceSSL = true;
          locations."/".return = 403; # Forbidden
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = "foo@bar.com";
      };

      networking = {
        firewall = {
          enable = false;
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
