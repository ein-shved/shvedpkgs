{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    home-manager = {
      url = github:nix-community/home-manager/release-23.05;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = github:numtide/flake-utils;
    hasp = {
      url = github:ein-shved/SentinelHasp.nix;
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, hasp, ... } @ attrs:
    let
      _modules = [
        ./config
        ./modules
        ./pkgs
      ];
      mkConfigs = hosts: flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          _lib = pkgs.callPackage ./lib { };
          mkConfig =
            { hostname
            , specialArgs ? { }
            , modules ? [ ]
            ,
            }: nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                lib = pkgs.lib // _lib;
              } // attrs // specialArgs;
              modules = _modules ++
                [
                  hasp.packages.${system}.module
                ]
                ++ modules;
            };
        in
        {
          packages = rec {
            nixosConfigurations = builtins.mapAttrs
              (hostname: v: mkConfig (v // { inherit hostname; }))
              hosts;
          };
        });
      mkConfig =
        { hostname
        , ...
        } @ attrs: mkConfigs { ${hostname} = attrs; };

      extend = self: { modules ? [ ]
                     , specialArgs ? { }
                     , prefix ? [ ]
                     , hosts ? { }
                     , ...
                     }@extraArgs:
        let
          mapConfigurations = configurations:
            builtins.mapAttrs
              (
                name: config:
                  let
                    globalExtended = config.extendModules {
                      inherit modules specialArgs prefix;
                    };
                    localExtended = globalExtended.extendModules
                      (if hosts ? ${name} then hosts.${name} else { });
                  in
                  localExtended
              )
              configurations;
          mapSystems = systems:
            builtins.mapAttrs
              (name: system:
                {
                  nixosConfigurations = mapConfigurations system.nixosConfigurations;
                })
              systems;
          updModules = self.modules ++ modules;
          updSelf = self // {
            packages = mapSystems self.packages;
            extend = extend updSelf;
            modules = updModules;
            inherit mkConfig;
          } // extraArgs;
        in
        updSelf;

      allConfigurations = mkConfigs {
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
              services.cntlm-gss = {
                enable = false;
                proxy = [ "proxy.example.com:81" ];
              };
              kl.domain.enable = true;
            }
          ];
        };
      };

    in
    extend ({ modules = _modules; } // allConfigurations) { };
}
