{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
    home-manager = {
      url = github:nix-community/home-manager;
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
        test = {
          modules = [ ./test/vm/configuration.nix ];
        };
        test2 = {
          modules = [ ./test/vm/configuration.nix ];
        };
    };
}
