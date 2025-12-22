{
  pkgs,
  config,
  lib,
  isHomeManager,
  ...
}:
let
  inherit (config.hardware) needGraphic;
in
{
  config = {
    qt = {
      enable = true;
      platformTheme = "gnome";
      style.name = "adwaita-dark";
    };
    environment.graphicPackages = with pkgs;  [
      networkmanagerapplet
    ];
  } // (if isHomeManager then {
    fonts.fontconfig.enable = true;
    home.packages = [
      pkgs.nerd-fonts.jetbrains-mono
    ];
  } else {
    time.timeZone = "Europe/Moscow";
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    i18n.extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
    programs.nm-applet.enable = needGraphic;
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
  });
}
