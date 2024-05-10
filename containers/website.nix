{ pkgs, ... }: {
  containers.website = {
    autoStart = true;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "192.168.100.5/24";
    config = {
      services.httpd = {
        enable = true;
        adminAddr = "morty@example.org";
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
