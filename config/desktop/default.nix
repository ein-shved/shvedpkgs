{ config, pkgs, lib, ... }:
with pkgs;
{
  imports = [
    ./xdg
  ];
  config = {
    programs.hyprland.enable = true;
    services.xserver = {
      enable = true;
      layout = "us,ru";
      displayManager.gdm = {
        enable = true;
        debug = true;
        wayland = true;
      };
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
    programs.nm-applet.enable = true;
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
  };
}

