{
  pkgs,
  config,
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
    services.displayManager = {
      enable = true;
      autoLogin = {
        enable = true;
        user = config.user.name;
      };
      defaultSession = "niri";
      sddm = {
        enable = true;
        wayland.enable = true;
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
  };
}
