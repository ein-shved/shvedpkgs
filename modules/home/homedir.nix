{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  active = config.home.enable && options.user.name.isDefined;
  name = config.user.name;
  cfg = config.home-manager.users.${name}.home;

  dummy = pkgs.runCommand "dummy" { } "mkdir $out";
in
{
  options = {
    home.enable = lib.mkEnableOption "the primary user's Home Manager environment";
    home.refresh-profile.enable = lib.mkEnableOption "refreshing of nix profile upon startup";
    hm = lib.mkOption {
      description = "Deferred declarations for the primary Home Manager environment.";
      type = lib.types.deferredModule;
      default = { };
      apply =
        _:
        if active then
          config.home-manager.users.${name}
        else
          throw "config.hm: the primary Home Manager environment is not active.";
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = config.home.enable -> options.user.name.isDefined;
          message = "home.enable requires a configured user.name.";
        }
      ];
    }
    (lib.mkIf active (
      lib.mkMerge [
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.${name}.home.stateVersion = lib.mkDefault config.system.stateVersion;
        }
        {
          # Forward raw definitions with their sources and merge priority.
          # The projected config.hm value must not feed its own destination.
          home-manager.users.${name} = lib.mkMerge (
            map (
              def: lib.mkOverride options.hm.highestPrio (lib.setDefaultModuleLocation def.file def.value)
            ) options.hm.definitionsWithLocations
          );
        }
      ]
    ))
    # This will force HM to use modern approach of profile configuration on clean
    # systems
    {
      hm.home.activation.preInstallPackages = lib.mkIf config.home.refresh-profile.enable (
        lib.hm.dag.entryBefore [ "installPackages" ] ''
          if [ ! -e "${cfg.profileDirectory}/manifest.json" ]; then
            nix profile add ${dummy}
            nix profile remove ${dummy}
          fi
        ''
      );
    }
  ];
}
