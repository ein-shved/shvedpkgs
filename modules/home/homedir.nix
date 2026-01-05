{
  config,
  lib,
  flake-inputs,
  ...
}:
let
  name = config.user.name;
  hm = flake-inputs.home-manager.lib.hm;

  actSubmodule = with lib.types; {
    options = {
      script = mkOption {
        description = "The script text of home activation";
        type = str;
      };
      after = mkOption {
        description = "The entyAfter value";
        type = either str (listOf str);
        default = [ "writeBoundary" ];
      };
    };
  };

  activation = with lib.types; either str (submodule actSubmodule);

  activationMapper =
    name: act:
    if builtins.isString act then
      hm.dag.entryAfter [ "writeBoundary" ] act
    else
      hm.dag.entryAfter (lib.toList act.after) act.script;
in
{
  options = {
    home = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = ''
        The mirror for `config.home-manager.users.${name}`
      '';
      default = { };
    };
    home-activations = lib.mkOption {
      description = "List of local activations";
      type = lib.types.attrsOf activation;
      default = { };
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      users.${name} = lib.mkMerge [
        (lib.removeAttrs config.home [ "activations" ])
        { home.activation = lib.mapAttrs activationMapper config.home.activations; }
      ];
    };
    home-activations = config.home.activations;
    home.home.stateVersion = lib.mkDefault config.system.stateVersion;
  };

  imports = [
    flake-inputs.home-manager.nixosModules.default
  ];
}
