{
  pkgs,
  ...
}:
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
    services.xserver = {
      enable = true;
      xkb.layout = "us,ru";
      displayManager.gdm = {
        enable = true;
        debug = true;
        wayland = true;
      };
    };
    fonts.packages = with pkgs; [
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
    environment.systemPackages = with pkgs; [
      networkmanagerapplet
    ];
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
  };
}
