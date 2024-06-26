{
  description = "Trabalho de Admnistracao de Sistemas em Rede";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
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

      nixosConfigurations.vm =
        nixpkgs.lib.genAttrs (darwinSystems ++ linuxSystems) (s:
          let sys = if s == "aarch64-darwin" || s == "aarch64-linux" then "aarch64-linux" else "x86_64-linux"; in
          nixpkgs.lib.nixosSystem {
            system = sys;
            specialArgs = inputs;
            modules = [
              home-manager.nixosModules.home-manager {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users."guest" = import ./hosts/home.nix;
                };
              }
              {
                virtualisation = {
                  vmVariant.virtualisation = {
                    cores = 6;
                    memorySize = 8000;
                    graphics = false;
                    resolution = { x = 1900; y = 1200; };
                    host.pkgs = nixpkgs.legacyPackages.${s};
                  };
                };
              }
              ./hosts/system.nix

              ./containers/websites.nix # includes email server
              ./containers/log.nix
              ./containers/dns.nix
              ./containers/log.nix
              ./containers/proxy.nix
              ./containers/dhcp.nix
              ./containers/backup.nix
              ./containers/outside.nix
              ./containers/guest.nix
            ];
          });
    };
}
