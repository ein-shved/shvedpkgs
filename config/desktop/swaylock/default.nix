{
  lib,
  config,
  pkgs,
  ...
}:
let
  mkMonitor = name: lib.optionalString (name != "default" && name != null) "${name}:";
  mkBlurOutput =
    output:
    pkgs.mkblur {
      src = output.wallpaper;
      blur = "0x20";
    };
  mkImage =
    name: output:
    lib.optionalString ((output.wallpaper or null) != null) "${mkMonitor name}${mkBlurOutput output}";
  images = lib.mapAttrsToList mkImage config.hardware.wallpaperMonitors;

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
