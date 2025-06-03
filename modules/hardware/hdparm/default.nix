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
    removePrefix
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

  mkServiceName =
    name:
    "hard-drive-standby-${replaceStrings [ "/" ] [ "-" ] (removePrefix "/" name)}";

  mkDrives =
    foo:
    mapAttrs' (
      name: value: nameValuePair (mkServiceName name) (foo name value)
    ) config.hardware.drives;
in
{
  options = {
    hardware.drives = lib.mkOption {
      type = attrsOf (submodule drive);
      default = { };
    };
  };
  config.systemd = {
    services = mkDrives (
      name: value: {
        path = with pkgs; [ hdparm ];
        script = ''
          if ! hdparm -C ${name} | grep -q 'standby\|unknown'; then
            hdparm -S ${builtins.toString value.standby.timeout} ${name}
          fi
        '';
        serviceConfig.Type = "oneshot";
      }
    );
    timers = mkDrives (
      name: value: {
        wantedBy = [ "timers.target" ];
        enable = value.standby.enable;
        # Periodically refresh configuration, because usage shows that this
        # configuration can be disabled somehow.
        timerConfig =
          let
            secs = value.standby.timeout * 5;
          in
          {
            Persistent = true;
            OnBootSec = secs;
            OnUnitActiveSec = secs;
            Unite = mkServiceName name;
          };
      }
    );
  };
}
