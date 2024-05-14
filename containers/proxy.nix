{ pkgs, ... }:
{
  containers.websites = {
    autoStart = true;
    privateNetwork = false;
    # hostBridge = "br0"; # Specify the bridge name
    # localAddress = "10.0.0.3/24";
    config = {
      services.getty.autologinUser = "guest";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      interfaces."eth1".ipv4.addresses = [
        {
          address = "81.104.20.2";
          prefixLength = 24;
        }
      ];

      security.sudo.wheelNeedsPassword = false;

      # services.nginx.enable = true;
      # services.nginx.virtualHosts."admin.futuretech.pt" = {
      #   addSSL = true;
      #   enableACME = true;
      #   root = "/etc/www/admin";
      #   locations."/".extraConfig = ''
      #     allow 10.0.0.0/16;
      #     deny all; # Deny all other IPs
      #   '';
      # };
      #
      # services.nginx.virtualHosts."gestao.futuretech.pt" = {
      #   addSSL = true;
      #   enableACME = true;
      #   root = "/etc/www/gestao";
      #   locations."/".extraConfig = ''
      #     allow 10.0.0.0/16;
      #     deny all; # Deny all other IPs
      #   '';
      # };
      #
      # services.nginx.virtualHosts."clientes.futuretech.pt" = {
      #   addSSL = true;
      #   enableACME = true;
      #   root = "/etc/www/clientes";
      # };
      #
      # security.acme = {
      #   acceptTerms = true;
      #   defaults.email = "foo@bar.com";
      # };
      #
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
