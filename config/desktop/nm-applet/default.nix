{
  config,
  ...
}:
{
  programs.nm-applet.enable = config.hardware.isGraphic;
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
