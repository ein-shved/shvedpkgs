{ config, pkgs, lib, ... }:
with pkgs;
{
  config = {
    services.xserver = {
      enable = true;
      desktopManager.xfce = {
        enable = true;
      };
      displayManager =  {
        lightdm = {
            enable = true;
        };
        defaultSession = "xfce";
      };
      useGlamor = true;
      layout = "us,ru";
    };
    fonts.fonts = [
      jetbrains-mono
    ];
    time.timeZone = "Europe/Moscow";
    qt5 = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    environment.systemPackages = with xfce; [
      xfce4-battery-plugin
      xfce4-clipman-plugin
      xfce4-pulseaudio-plugin
      xfce4-xkb-plugin
    ];
    programs.nm-applet.enable = true;
  };
}
