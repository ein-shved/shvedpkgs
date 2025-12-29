{
  isHomeManager,
  lib,
  config,
  pkgs,
  ...
}:
let
  mkMonitorName = name: lib.strings.removePrefix "desc:" name;
  mkMonitor = name: lib.optionalString (name != "default" && name != null) "${mkMonitorName name}:";
  mkBlurOutput = output: pkgs.mkblur { src = output.wallpaper; blur = "0x20"; };
  mkImage =
    name: output:
    lib.optionalString ((output.wallpaper or null) != null) "${mkMonitor name}${mkBlurOutput output}";
  filteredMonitors = lib.filterAttrs (
    name: value: value ? wallpaper && value.wallpaper != null
  ) config.hardware.aliasedMonitors;
  image = lib.mapAttrsToList mkImage filteredMonitors;
in
{
  programs.swaylock-upd = {
    enable = true;
    settings = {
      color = "000000";
      show-keyboard-layout = true;
      # image = lib.elemAt image 0;
      # TODO(Shvedov): fix in HM
      inherit image;
    };
  }
  // (lib.optionalAttrs isHomeManager) {
    package = null;
  };
}
