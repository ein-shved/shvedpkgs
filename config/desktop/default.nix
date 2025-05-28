{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.hardware) needGraphic;
in
{
  imports = [
    ./anyrun
    ./hyprland
    ./kitty
    ./niri
    ./waybar
    ./wpaperd
    ./xdg
  ];
  config = {
    services.displayManager = {
      enable = needGraphic;
      autoLogin = {
        enable = true;
        user = config.user.name;
      };
      defaultSession = "niri";
      sddm = {
        enable = needGraphic;
        wayland.enable = true;
      };
    };
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
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
    programs.nm-applet.enable = needGraphic;
    environment.graphicPackages = with pkgs;  [
      networkmanagerapplet
    ];
  };
}
