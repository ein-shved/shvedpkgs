{
  config,
  lib,
  ...
}:
{
  home.services.wpaperd = {
    enable = config.hardware.needGraphic;
    settings = lib.mapAttrs (_: mon: {
      path = mon.wallpaper;
    }) config.hardware.wallpaperMonitors;
  };
  home-manager.users.${config.user.name}.systemd.user.services.wpaperd = {
    Unit.After = [ "niri.service" ];
    Unit.ConditionEnvironment = lib.mkForce "";

    Service = {
      Restart = lib.mkForce "on-failure";
      RestartSec = lib.mkForce "100ms";
    };
  };
}
