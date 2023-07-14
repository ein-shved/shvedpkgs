{ config, pkgs, home-manager, ... }:
with pkgs.lib;
let
  cfg = config.home;
  name = config.user.name;
  hm = home-manager.lib;

  actSubmodule = with types; {
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

  activation = types.either types.str (types.submodule actSubmodule);

  activationMapper = name: act:
    let
      dag = hm.dag;
    in
    if builtins.isString act then
      dag.entryAfter [ "writeBoundary" ] act
    else
      dag.entryAfter (toList act.after) act.script;

  mkHomeOption = name: mkOption {
    description = "Mirror of home-manager ${name} configuration";
    type = types.attrsOf types.anything;
    default = { };
  };

  extra = with types; submodule {
    options = {
      section = mkOption {
        type = str;
      };
      value = mkOption {
        type = anything;
      };
    };
  };

  loadExtras = section: list:
    let
      sections = builtins.filter (x: x.section == section) list;
    in
    mkMerge (map (x: x.value) sections);

in
{

  options = {
    home = {
      activations = mkOption {
        description = "List of local activations";
        type = types.attrsOf activation;
        default = { };
      };
      home = mkHomeOption "home";
      programs = mkHomeOption "programs";
      xdg = mkHomeOption "xdg";
      extras = mkOption {
        description = ''
          Workaround to allow split configuration of homedir and allow config
          to be joinable.
        '';
        type = types.listOf extra;
        default = [ ];
      };
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      users.${name} = {
        home = mkMerge [
          {
            activation = builtins.mapAttrs activationMapper cfg.activations;
            stateVersion = "23.05";
          }
          cfg.home
          (loadExtras "home" cfg.extras)
        ];
        programs = mkMerge [
          cfg.programs
          (loadExtras "programs" cfg.extras)
        ];
        xdg = mkMerge [
          cfg.xdg
          (loadExtras "xdg" cfg.extras)
        ];
      };
    };
  };

  imports = [
    home-manager.nixosModules.default
  ];

}
