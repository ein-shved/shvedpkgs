{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    home-manager = {
      url = github:nix-community/home-manager/release-23.05;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils, ... } @ attrs:
    let
      _modules = [
        ./nixos/modules
        ./nixos/pkgs
      ];
      mkConfigs = hosts: flake-utils.lib.eachDefaultSystem (system:
        let
          mkConfig =
            { hostname
            , specialArgs ? { }
            , modules ? [ ]
            ,
            }: nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = attrs // specialArgs;
              modules = _modules ++ modules;
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
    in
    {
      modules = _modules;
      inherit mkConfig;
    } // mkConfigs {
      testA = {
        modules = [
          ./test/vm/configuration.nix
          {
            user = {
              name = "alice";
              humanName = "Alice";
              password = "alice";
            };
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
          }
        ];
      };
    };
}
