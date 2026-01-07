{
  hardware.singleOutput.enable = true;
  hardware.monitors = {
    "XMI Mi Monitor 0000000000000" = {
      resolution = "3440x1440";
      position = "0x0";
      scale = "1";
      aliases = [
        "Xiaomi Corporation Mi Monitor 0000000000000"
        "Xiaomi Corporation Mi Monitor Unknown"
        "DP-0"
        "DP-1"
        "DP-2"
        "DP-3"
        "DP-4"
        "DP-5"
      ];
      isDefault = true;
    };
    default = {
      enable = false;
      wallpaper = ./wallpapers/DeadSpace.jpg;
    };
  };
}
