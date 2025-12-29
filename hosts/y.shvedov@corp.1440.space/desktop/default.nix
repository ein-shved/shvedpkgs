{
  hardware.monitors = {
    eDP-1 = {
      resolution = "1920x1080";
      position = "0x0";
      scale = "1";
      wallpaper = ./wallpapers/Demeter.jpg;
    };
    default = {
      position = "auto-right";
      wallpaper = ./wallpapers/RoR2.jpg;
    };
    # Found out that description of this monitor changes
    "XMI Mi Monitor" = {
      resolution = "3440x1440";
      position = "-760x1080";
      scale = "1";
      wallpaper = ./wallpapers/OuterWilds.png;
      aliases = [
        "XMI Mi Monitor 0000000000000"
        "Xiaomi Corporation Mi Monitor 0000000000000"
        "Xiaomi Corporation - Mi Monitor - DP-1"
        "Xiaomi Corporation - Mi Monitor - HDMI-A-1"
        "Xiaomi Corporation Mi Monitor 0000000000000 - HDMI-A-1"
        "re:Xiaomi Corporation - Mi Monitor"
      ];
    };
  };
}
