lib: prev: {
  transformNixosPackages =
    nixosConfigurations:
    {
      default ? "generic",
    }:
    let
      packages-lists = lib.mapAttrsToList (name: host: {
        inherit name;
        system = host.pkgs.stdenv.hostPlatform.system;
        pkgs = host.pkgs // {
          images = host.config.formats;
        };
      }) nixosConfigurations;

      packages = lib.foldl' (
        prev:
        {
          system,
          name,
          pkgs,
        }:
        prev
        // {
          ${system} =
            (prev.${system} or { })
            // {
              ${name} = pkgs;
            }
            // lib.optionalAttrs (name == default) pkgs;
        }
      ) { } packages-lists;

    in
    packages;

  mkExtendableSystems =
    self:
    {
      modules ? [ ],
      validationModules ? [
        ../tests/modules/stubs/private-values
      ],
      specialArgs ? { },
      prefix ? [ ],
      hosts ? { },
      ...
    }@extraArgs:
    let
      mkNixosConfigurations =
        extraModules:
        builtins.mapAttrs (
          name: config:
          let
            hostconfig = config // {
              specialArgs = (config.specialArgs or { }) // extendedSelf.specialArgs;
              modules = (config.modules or [ ]) ++ extendedSelf.modules ++ extraModules;
              prefix = (config.prefix or [ ]) ++ extendedSelf.prefix;
            };
          in
          extendedSelf.mkSystem ({ inherit (extendedSelf) defaultSystem; } // hostconfig)
        ) extendedSelf.hosts;

      nixosConfigurations = mkNixosConfigurations [ ];
      nixosValidationConfigurations = mkNixosConfigurations extendedSelf.validationModules;

      extendedSelf =
        self
        // extraArgs
        // {
          modules = (self.modules or [ ]) ++ modules;
          validationModules = (self.validationModules or [ ]) ++ validationModules;
          specialArgs = (self.specialArgs or { }) // specialArgs;
          prefix = (self.prefix or [ ]) ++ prefix;
          hosts = (self.hosts or { }) // hosts;

          nixosConfigurations = nixosConfigurations;
          nixosValidationConfigurations = nixosValidationConfigurations;
          extend = lib.mkExtendableSystems extendedSelf;

          packages = lib.transformNixosPackages nixosConfigurations {
            default = extendedSelf.defaultHost;
          };
        };
    in
    extendedSelf;
}
