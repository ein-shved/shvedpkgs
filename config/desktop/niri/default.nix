{ pkgs, ... }:
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
    ];
  };
}
