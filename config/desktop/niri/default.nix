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
      pavucontrol
      swaynotificationcenter
      udiskie
      waybar
      wl-clipboard
      wpaperd
    ];
  };
}
