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
    fonts.packages = [
      jetbrains-mono
      nerdfonts
    ];
    time.timeZone = "Europe/Moscow";
    i18n.extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
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

