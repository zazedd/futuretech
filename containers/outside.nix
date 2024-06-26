{ pkgs, ... }: {
  containers.outside = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "82.103.20.3/24";
    ephemeral = true; # makes the container stateless, it will reset on restart
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

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 443 ];
          allowedUDPPorts = [ 443 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
        # Simular a existencia de um DNS na internet que tenha um A record para a futuretech.pt 
        # e CNAMEs para os outros
        extraHosts = '' 
          82.103.20.2 futuretech.pt
          82.103.20.2 admin.futuretech.pt
          82.103.20.2 gestao.futuretech.pt
          82.103.20.2 clientes.futuretech.pt
        '';
      };

      system.stateVersion = "24.05";
    };
  };
}
