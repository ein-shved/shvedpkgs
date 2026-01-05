{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      agenix,
      vim,
      niri-flake,
      niri,
      unstable,
      nix-index-database,
      ...
    }@attrs:
    let
      _defaultSystem = "x86_64-linux";
      nixosModules = [
        ./config
        ./modules/nixos.nix
        ./pkgs
        agenix.nixosModules.default
        vim.nixosModules.default
        niri-flake.nixosModules.niri
        nix-index-database.nixosModules.nix-index
        {
          nixpkgs.overlays = [
            agenix.overlays.default
            niri.overlays.default
          ];
        }
      ];
      mkConfigs =
        hosts:
        let
          mkConfig =
            {
              system ? _defaultSystem,
              pkgs ? nixpkgs.legacyPackages.${system},
              specialArgs ? { },
              modules ? [ ],
            }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                lib = pkgs.lib // (import ./lib { lib = pkgs.lib; });
                inherit system;
                inherit (pkgs) path;
                pkgsUnstable = import unstable { inherit system; };
              }
              // attrs
              // specialArgs;
              modules = nixosModules ++ modules;
            };
        in
        {
          nixosConfigurations = builtins.mapAttrs (_: v: mkConfig v) hosts;
        };

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
                localExtended = globalExtended.extendModules (if hosts ? ${name} then hosts.${name} else { });
              in
              localExtended
            ) configurations;
          updModules = self.modules ++ modules;
          updSelf =
            self
            // {
              nixosConfigurations = mapConfigurations self.nixosConfigurations;
              extend = extend updSelf;
              modules = updModules;
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
    extend ({ modules = nixosModules; } // allConfigurations) { };
}
