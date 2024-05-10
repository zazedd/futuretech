{
  description = "Trabalho de Admnistracao de Sistemas em Rede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkDarwinApps = system: {
        "run" = mkApp "run" system;
      };
      mkLinuxApps = system: {
        "run" = mkApp "run" system;
      };
    in
    {

      formatter = nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      nixosConfigurations.container =
        nixpkgs.lib.genAttrs (darwinSystems ++ linuxSystems) (s:
          let sys = if s == "aarch64-darwin" then "aarch64-linux" else "x86_64-linux"; in
          nixpkgs.lib.nixosSystem {
            system = sys;
            modules = [{
              virtualisation = {
                vmVariant.virtualisation = {
                  graphics = false;
                  resolution = { x = 1900; y = 1200; };
                  host.pkgs = nixpkgs.legacyPackages.${s};
                };
              };
            }

              ({ pkgs, ... }: {
                services.getty.autologinUser = "guest";
                users.users."guest" = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                  password = "123";
                };

                security.sudo.wheelNeedsPassword = false;

                # Let 'nixos-version --json' know about the Git revision
                # of this flake.
                system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

                # Network configuration.
                networking = {
                  bridges.br0.interfaces = [ "eth0" ]; # Adjust interface accordingly

                  useDHCP = false;
                  interfaces."br0".useDHCP = true;

                  interfaces."br0".ipv4.addresses = [{
                    address = "192.168.100.3";
                    prefixLength = 24;
                  }];
                  defaultGateway = "192.168.100.1";
                  nameservers = [ "192.168.100.1" ];
                };


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
                      # Use systemd-resolved inside the container
                      # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
                      useHostResolvConf = pkgs.lib.mkForce false;
                    };

                    services.resolved.enable = true;
                  };
                };
              })];
          });
    };
}
