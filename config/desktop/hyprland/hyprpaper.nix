{ config, lib, ... }:
let
  monitors = config.hardware.aliasedMonitors;
in
{
  config.programs.hyprland.hyprconfig.hyprpaper = {
    text =
      let
        mkMonitor = name: lib.optionalString (name != "default") name;
        mkWallpaper = name: value: ''
          wallpaper = ${mkMonitor name}, ${value.wallpaper}
        '';
        wallpapers = lib.foldlAttrs (
          acc: name: value:
          acc + (mkWallpaper name value)
        ) "" wallpaperMons;

        preloads = lib.foldlAttrs (
          acc: name: value:
          acc + "preload = ${value.wallpaper}\n"
        ) "" wallpaperMons;

        wallpaperMons = lib.filterAttrs (
          name: value: value ? wallpaper && value.wallpaper != null
        ) monitors;

      in
      ''
        ${preloads}

        ${wallpapers}

        splash = true
      '';
  };
}
