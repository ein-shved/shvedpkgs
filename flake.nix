{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    agenix = {
      url = "github:ryantm/agenix/0.15.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    vim = {
      url = "github:ein-shved/vim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    niri = {
      url = "github:ein-shved/niri/view_offset";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs =
    {
      nixpkgs,
      flake-utils,
      agenix,
      vim,
      niri-flake,
      niri,
      ...
    }@attrs:
    let
      _modules = [
        ./config
        ./modules
        ./pkgs
        agenix.nixosModules.default
        vim.nixosModules.default
        niri-flake.nixosModules.niri
        {
          nixpkgs.overlays = [
            agenix.overlays.default
            niri.overlays.default
          ];
        }
      ];
      mkConfigs =
        hosts:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs { inherit system; };
            _lib = import ./lib { lib = pkgs.lib; };

            mkDevShellFor =
              config: name:
              pkgs.mkShell {
                packages = builtins.filter (
                  pkg: pkgs.lib.getName pkg.name == name
                ) config.environment.systemPackages;
              };

            mkDevShellsFor =
              config: names:
              builtins.listToAttrs (
                map (name: {
                  inherit name;
                  value = mkDevShellFor config name;
                }) names
              );

            mkConfig =
              {
                hostname,
                specialArgs ? { },
                modules ? [ ],
              }:
              nixpkgs.lib.nixosSystem {
                inherit system;
                specialArgs =
                  {
                    lib = pkgs.lib // _lib;
                    inherit system;
                    inherit (pkgs) path;
                  }
                  // attrs
                  // specialArgs;
                modules = _modules ++ modules;
              };
          in
          rec {
            packages = {
              nixosConfigurations = builtins.mapAttrs (
                hostname: v: mkConfig (v // { inherit hostname; })
              ) hosts;
            };
            devShells = mkDevShellsFor packages.nixosConfigurations.generic.config [
              "neovim"
            ];
          }
        );

      mkConfig = { hostname, ... }@attrs: mkConfigs { ${hostname} = attrs; };

      extend =
        self:
        {
          modules ? [ ],
          specialArgs ? { },
          prefix ? [ ],
          hosts ? { },
          ...
        }@extraArgs:
        let
          mapConfigurations =
            configurations:
            builtins.mapAttrs (
              name: config:
              let
                globalExtended = config.extendModules { inherit modules specialArgs prefix; };
                localExtended = globalExtended.extendModules (
                  if hosts ? ${name} then hosts.${name} else { }
                );
              in
              localExtended
            ) configurations;
          mapSystems =
            systems:
            builtins.mapAttrs (name: system: {
              nixosConfigurations = mapConfigurations system.nixosConfigurations;
            }) systems;
          updModules = self.modules ++ modules;
          updSelf =
            self
            // {
              packages = mapSystems self.packages;
              extend = extend updSelf;
              modules = updModules;
              inherit mkConfig;
            }
            // extraArgs;
        in
        updSelf;

      allConfigurations = mkConfigs (
        {
          generic = {
            modules = [ { user.name = "NixOS"; } ];
          };
          # Run with
          # nixos-rebuild build-vm --flake .#testA && \
          # QEMU_NET_OPTS="hostfwd=tcp::2221-:22" ./result/bin/run-nixos-vm
          testA = {
            modules = [
              ./test/vm/configuration.nix
              {
                user = {
                  name = "alice";
                  humanName = "Alice Cooper";
                  password = "alice";
                };
                kl.remote.enable = true;
              }
            ];
          };
          testB = {
            modules = [
              ./test/vm/configuration.nix
              {
                user = {
                  name = "bob";
                  humanName = "Bob";
                  password = "bob";
                };
                environment.printing3d.enable = true;
                kl.domain.enable = true;
              }
            ];
          };
          testNas = {
            modules = [
              ./test/vm/configuration.nix
              {
                user = {
                  name = "nas";
                  humanName = "Nas";
                  password = "nas";
                };
                hardware.isNas = true;
              }
            ];
          };
        }
        // import ./hosts
      );

    in
    extend ({ modules = _modules; } // allConfigurations) { };
}
