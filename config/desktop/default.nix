{ config, pkgs, lib, ... }:
with pkgs;
{
  imports = [
    ./xdg
  ];
  config = {
    services.xserver = {
      enable = true;
      desktopManager = {
        xfce.enable = true;
        xterm.enable = false;
      };
      displayManager =  {
        defaultSession = "xfce";
      };
      layout = "us,ru";
    };
    fonts.fonts = [
      jetbrains-mono
      nerdfonts
    ];
    time.timeZone = "Europe/Moscow";
    qt = {
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
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
  };
}

