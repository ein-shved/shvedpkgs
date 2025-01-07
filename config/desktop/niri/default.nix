{ pkgs, config, ... }:
let
  singleOutput = config.hardware.singleOutput;
in
{
  imports = [
    ./niri.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      alsa-utils
      anyrun
      brightnessctl
      hypridle
      hyprlock
      niri-launch-terminal
      pavucontrol
      swaynotificationcenter
      udiskie
      waybar
      wl-clipboard
      wpaperd
      xwayland-satellite
    ] ++ (lib.optional singleOutput.enable niri-single-output);
  };
}
