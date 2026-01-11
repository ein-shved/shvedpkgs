{
  config,
  lib,
  flake-inputs,
  pkgs,
  ...
}:
let
  name = config.user.name;
  cfg = config.home-manager.users.${name}.home;

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
      lib.hm.dag.entryAfter [ "writeBoundary" ] act
    else
      lib.hm.dag.entryAfter (lib.toList act.after) act.script;

  # This will force HM to use modern approach of profile configuration on clean
  # systems
  initial =
    let
      dummy = pkgs.runCommand "dummy" { } "mkdir $out";
    in
    {
      home.activation.preInstallPackages = lib.hm.dag.entryBefore [ "installPackages" ] ''
        if [ ! -e "${cfg.profileDirectory}/manifest.json" ]; then
          nix profile add ${dummy}
          nix profile remove ${dummy}
        fi
      '';
    };
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
        initial
      ];
    };
    home-activations = config.home.activations;
    home.home.stateVersion = lib.mkDefault config.system.stateVersion;
  };

  imports = [
    flake-inputs.home-manager.nixosModules.default
  ];
}
