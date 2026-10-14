{
  config,
  lib,
  ...
}:
let
  mkGraphic = lib.mkIf config.hardware.isGraphic;
in
{
  hm.services.awww = mkGraphic {
    enable = config.hardware.isGraphic;
  };
  hm.systemd = mkGraphic {
    user.services.awww = {
      Unit.After = [ "niri.service" ];
      Unit.ConditionEnvironment = lib.mkForce "";

      Service = {
        Restart = lib.mkForce "on-failure";
        RestartSec = lib.mkForce "100ms";
      };
    };
  };
}

