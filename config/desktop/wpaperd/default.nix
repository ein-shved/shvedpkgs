{
  config,
  lib,
  ...
}:
let
  mkGraphic = lib.mkIf config.hardware.needGraphic;
in
{
  hm.services.wpaperd = mkGraphic {
    enable = config.hardware.needGraphic;
    settings = lib.mapAttrs (_: mon: {
      path = mon.wallpaper;
    }) config.hardware.wallpaperMonitors;
  };
  hm.systemd = mkGraphic {
    user.services.wpaperd = {
      Unit.After = [ "niri.service" ];
      Unit.ConditionEnvironment = lib.mkForce "";

      Service = {
        Restart = lib.mkForce "on-failure";
        RestartSec = lib.mkForce "100ms";
      };
    };
  };
}
