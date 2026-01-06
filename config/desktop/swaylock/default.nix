{
  lib,
  config,
  pkgs,
  ...
}:
let
  mkMonitorName = name: lib.strings.removePrefix "desc:" name;
  mkMonitor = name: lib.optionalString (name != "default" && name != null) "${mkMonitorName name}:";
  mkBlurOutput =
    output:
    pkgs.mkblur {
      src = output.wallpaper;
      blur = "0x20";
    };
  mkImage =
    name: output:
    lib.optionalString ((output.wallpaper or null) != null) "${mkMonitor name}${mkBlurOutput output}";
  filteredMonitors = lib.filterAttrs (
    name: value: value ? wallpaper && value.wallpaper != null
  ) config.hardware.aliasedMonitors;
  images = lib.mapAttrsToList mkImage filteredMonitors;

  # Home manager does not support multiple image specifying with config. So wrap
  # application with arguments provided
  package =
    pkgs.runCommand "swaylock-images"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      }
      ''
        makeWrapper "${lib.getExe pkgs.swaylock}" "$out/bin/swaylock" \
          ${lib.concatStringsSep " " (lib.map (image: ''--add-flags "--image ${image}"'') images)}
      '';
in
{
  home.programs.swaylock = {
    enable = true;
    settings = {
      color = "000000";
      show-keyboard-layout = true;
    };
    inherit package;
  };
}
