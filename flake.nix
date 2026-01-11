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
    }@flake-inputs:
    let
      _defaultSystem = "x86_64-linux";
      nixosModules = [
        ./config/nixos.nix
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
      loadPkgsFrom =
        input: system:
        import input {
          inherit system;
        };
      loadPkgs = loadPkgsFrom nixpkgs;
      loadPkgsUnstable = loadPkgsFrom unstable;
      mkConfigs =
        hosts:
        let
          mkConfig =
            {
              system ? _defaultSystem,
              pkgs ? loadPkgs system,
              specialArgs ? { },
              modules ? [ ],
            }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit flake-inputs;
                lib =
                  pkgs.lib
                  // (import ./lib {
                    inherit (pkgs) lib path;
                    inherit flake-inputs;
                  });
                pkgsUnstable = loadPkgsUnstable system;
              }
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

      allConfigurations = mkConfigs (import ./hosts);
    in
    extend ({ modules = nixosModules; } // allConfigurations) { };
}
