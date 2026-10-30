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
      # Define options and implement features shared by hosts and project tests.
      modules ? [ ],
      # Select and configure features for hosts only; project tests omit these modules.
      configs ? [ ],
      validationModules ? [
        ../tests/modules/stubs/private-values
      ],
      specialArgs ? { },
      prefix ? [ ],
      hosts ? { },
      # Flat checks for defaultSystem; matching names override inherited checks.
      checks ? { },
      ...
    }@extraArgs:
    let
      mkNixosConfigurations =
        extraModules:
        builtins.mapAttrs (
          name: host:
          let
            hostconfig = host // {
              specialArgs = (host.specialArgs or { }) // extendedSelf.specialArgs;
              modules = (host.modules or [ ]) ++ extendedSelf.modules;
              configs = (host.configs or [ ]) ++ extendedSelf.configs ++ extraModules;
              prefix = (host.prefix or [ ]) ++ extendedSelf.prefix;
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
          configs = (self.configs or [ ]) ++ configs;
          validationModules = (self.validationModules or [ ]) ++ validationModules;
          specialArgs = (self.specialArgs or { }) // specialArgs;
          prefix = (self.prefix or [ ]) ++ prefix;
          hosts = (self.hosts or { }) // hosts;
          checks = (self.checks or { }) // {
            ${extendedSelf.defaultSystem} =
              (self.checks.${extendedSelf.defaultSystem} or { }) // checks;
          };

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
