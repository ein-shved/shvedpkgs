{
  programs.hyprland.monitors =
    let
      ultrawide = {
        resolution = "3440x1440";
        position = "-760x1080";
        scale = "1";
        wallpaper = ./wallpapers/OuterWilds.png;
      };
    in
    {
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
      "desc:XMI Mi Monitor 0000000000000" = ultrawide;
      "desc:Xiaomi Corporation Mi Monitor 0000000000000" = ultrawide;
    };
}
