{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mapAttrs'
    mkEnableOption
    mkOption
    nameValuePair
    replaceStrings
    ;
  inherit (lib.types) ints submodule attrsOf;
  drive = {
    options = {
      standby.enable = mkEnableOption "standby by idle mode";
      standby.timeout = mkOption {
        type = ints.unsigned;
        description = ''
          See hdparm -S option
        '';
      };
    };
  };
in
{
  options = {
    hardware.drives = lib.mkOption {
      type = attrsOf (submodule drive);
      default = { };
    };
  };
  config.systemd.services = mapAttrs' (
    name: value:
    nameValuePair "hard-drive-standby-${replaceStrings [ "/" ] [ "-" ] name}" {
      enable = value.standby.enable;
      script = ''
        ${pkgs.hdparm}/bin/hdparm -S ${builtins.toString value.standby.timeout} ${name}
      '';
      after = [ "nix-store.mount" ];
      wantedBy = [ "multi-user.target" ];
    }
  ) config.hardware.drives;
}
