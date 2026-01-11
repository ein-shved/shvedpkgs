{
  config,
  ...
}:
{
  programs.nm-applet.enable = config.hardware.needGraphic;
  systemd.user.services.nm-applet = {
    after = [
      "waybar.service"
      "niri.service"
    ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "100ms";
    };
  };
}
