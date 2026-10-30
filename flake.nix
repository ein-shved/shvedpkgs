{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disco = {
      url = "github:nix-community/disko/latest";
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
      nixos-generators,
      home-manager,
      disco,
      ...
    }@flake-inputs:
    let
      lib = import ./lib flake-inputs;

      nixosModules = [
        ./modules/nixos.nix
        ./pkgs

        agenix.nixosModules.default
        vim.nixosModules.default
        home-manager.nixosModules.default
        niri-flake.nixosModules.niri
        nix-index-database.nixosModules.nix-index
        nixos-generators.nixosModules.all-formats
        disco.nixosModules.default

        {
          nixpkgs.overlays = [
            agenix.overlays.default
            niri.overlays.default
          ];
        }
      ];

      mkSystem =
        {
          system ? defaultSystem,
          specialArgs ? { },
          modules ? [ ],
          configs ? [ ],
          prefix ? [ ],
          defaultSystem,
        }:
        let
          extensions = (specialArgs.extensions or { }) // {
            inherit modules configs flake-inputs;
            pkgsUnstable = import unstable { inherit system; };
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system prefix;
          modules = modules ++ configs;
          specialArgs = specialArgs // {
            inherit extensions flake-inputs lib;
            inherit (extensions) pkgsUnstable;
          };
        };

      defaultSystem = "x86_64-linux";
    in
    /*
        generic usage:

        shvedpkgs.extend {
          hosts = {
            newHost = {
              system = "aarch64-linux"; # "x86_64-linux" by default
              configs = [
                ./newHostSpecialModule.nix;
              ];
            };
          };
          modules = [
            ./newGenericModule.nix
          ];
          configs = [
            ./newGenericConfiguration.nix
          ];
          checks.myCheck = someDerivation;
          defaultHost = "newHost"; # To force current hosts's packages be default
        };
    */
    lib.mkExtendableSystems {
      modules = nixosModules;
      configs = [ ./config/nixos.nix ];
      hosts = import ./hosts;
      inherit mkSystem defaultSystem;
      defaultHost = "generic";
      checks.${defaultSystem}.tests = flake-inputs.self.packages.${defaultSystem}.projectTests.allTests;
    } { };
}
