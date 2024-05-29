# Logging server
{ pkgs, ... }: {
  containers.log = {
    autoStart = false;
    privateNetwork = true;
    hostBridge = "br0"; # Specify the bridge name
    localAddress = "10.0.0.4/24";
    bindMounts = {
      # monta o /etc/resolv.conf do host, para partilhar os nameservers
      "/etc/resolv.conf" = {
        hostPath = "/etc/resolv.conf";
        isReadOnly = true;
      };
    };
    config = {
      services.getty.autologinUser = "guest";
      users.users."guest" = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "123";
      };

      security.sudo.wheelNeedsPassword = false;

      services.logrotate = {
        enable = true;

        settings."multiple paths" = {
          enable = true;
          files = [
            "/var/log/websites/nginx.log"
            "/var/log/websites/maddy.log"
            "/var/log/websites/acme.log"
            "/var/log/websites/messages"

            "/var/log/dns/nsd.log"
            "/var/log/dns/messages"

            "/var/log/proxy/nginx.log"
            "/var/log/proxy/acme.log"
            "/var/log/proxy/messages"

            "/var/log/dhcp/kea.log"
            "/var/log/dhcp/nginx.log"
            "/var/log/dhcp/messages"
          ];

          frequency = "hourly";
          rotate = 4;
        };
      };

      services.rsyslogd = {
        enable = true;
        extraConfig = ''
          # Provides TCP syslog reception
          module(load="imtcp")
          input(type="imtcp" port="514")

          # Provides UDP syslog reception
          module(load="imudp")
          input(type="imudp" port="514")

          template(name="RemoteLogs" type="string" string="/var/log/%HOSTNAME%/%PROGRAMNAME%.log")

          *.* ?RemoteLogs
        '';
      };

      networking = {
        firewall = {
          enable = true;
          allowedTCPPorts = [ 514 ];
          allowedUDPPorts = [ 514 ];
        };

        useHostResolvConf = pkgs.lib.mkForce false;
      };

      system.stateVersion = "24.05";
    };
  };
}
