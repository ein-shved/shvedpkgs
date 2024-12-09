{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrs' nameValuePair removePrefix;
  inherit (pkgs.formats) toml;

  toToml = (toml { }).generate "wpaperd";

  monitors = config.hardware.aliasedMonitors;
  wallpaperMons = lib.filterAttrs (
    name: value: value ? wallpaper && value.wallpaper != null
  ) monitors;
  mkMonitor = name: monitor: let
    name' = removePrefix "desc:" name;
    monitor' = { path = monitor.wallpaper; };
  in nameValuePair name' monitor';
  wallpapers = mapAttrs' mkMonitor wallpaperMons;
in
{
  home.xdg.configFile."wpaperd/config.toml" = {
    source = toToml wallpapers;
  };
}
