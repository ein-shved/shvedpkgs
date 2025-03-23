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
  imports = [
    ./niri.nix
  ];
  config = {
    environment.graphicPackages =
      with pkgs;
      [
        alsa-utils
        anyrun
        brightnessctl
        hyprlock
        niri-launch-terminal
        niri-launcher
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
