{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
        ./config/nixos.nix
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
          prefix ? [ ],
          defaultSystem,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system modules prefix;
          specialArgs = specialArgs // {
            inherit flake-inputs lib;
            pkgsUnstable = import unstable { inherit system; };
          };
        };
    in
    /*
        generic usage:

        shvedpkgs.extend {
          hosts = {
            newHost = {
              system = "aarch64-linux"; # "x86_64-linux" by default
              modules = [
                ./newHostSpecialModule.nix;
              ];
            };
          };
          modules = [
            ./newGenericModule.nix
          ];
          defaultHost = "newHost"; # To force current hosts's packages be default
        };
    */
    lib.mkExtendableSystems {
      modules = nixosModules;
      hosts = import ./hosts;
      inherit mkSystem;
      defaultSystem = "x86_64-linux";
      defaultHost = "generic";
    } { };
}
