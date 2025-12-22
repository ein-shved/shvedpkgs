{
  pkgs,
  config,
  lib,
  ...
}:
let
  singleOutput = config.hardware.singleOutput;
in
{
  config = {
    environment.graphicPackages =
      with pkgs;
      [
        alsa-utils
        anyrun
        brightnessctl
        hyprlock
        niri-launch-terminal
        niri-integration
        pavucontrol
        swaynotificationcenter
        udiskie
        waybar
        wayidle
        wl-clipboard
        wpaperd
        xwayland-satellite
      ]
      ++ (lib.optional singleOutput.enable niri-single-output);
  };
}
