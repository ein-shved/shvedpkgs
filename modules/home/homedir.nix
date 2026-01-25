{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = config.user.name;
  cfg = config.home-manager.users.${name}.home;

  dummy = pkgs.runCommand "dummy" { } "mkdir $out";
in
{
  options = {
    home.refresh-profile.enable = lib.mkEnableOption "refreshing of nix profile upon startup";
  };
  config = {
    home-manager = {
      useGlobalPkgs = true;
    };
    hm.home.stateVersion = lib.mkDefault config.system.stateVersion;
    # This will force HM to use modern approach of profile configuration on clean
    # systems
    hm.home.activation.preInstallPackages = lib.mkIf config.home.refresh-profile.enable (
      lib.hm.dag.entryBefore [ "installPackages" ] ''
        if [ ! -e "${cfg.profileDirectory}/manifest.json" ]; then
          nix profile add ${dummy}
          nix profile remove ${dummy}
        fi
      ''
    );
  };

  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" name ])
  ];
}
