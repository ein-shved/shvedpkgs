{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.hardware) needGraphic;

  mkMonitor = name: if name == "default" || name == null then "greeter" else "monitor: ${name}";
  mkBlurOutput =
    output:
    pkgs.mkblur {
      src = output.wallpaper;
      blur = "0x20";
    };

  mkImage = name: output: ''
    [${mkMonitor name}]
    background = ${mkBlurOutput output}
  '';

  images = lib.mapAttrsToList mkImage config.hardware.wallpaperMonitors;
  default-outputs = builtins.attrNames (
    lib.filterAttrs (_: v: v.isDefault) config.hardware.aliasedMonitors
  );
in
{
  services.displayManager.defaultSession = "niri";
  services.xserver.enable = true;
  services.xserver.displayManager = {
    lightdm = {
      enable = needGraphic;
      greeters.gtk = {
        enable = true;
        cursorTheme = {
          inherit (config.home.home.pointerCursor) package name size;
        };
        inherit (config.home.gtk) theme iconTheme;
        extraConfig = ''
          [greeter]
          xft-dpi = 144
        ''
        + lib.concatStringsSep "\n" images;
      };
      extraSeatDefaults = lib.mkIf config.hardware.singleOutput.enable ''
        display-setup-script=${
          lib.getExe (
            pkgs.lightdm-single-output.override {
              default-user = config.user.name;
              inherit default-outputs;
            }
          )
        }
      '';
    };
  };
}
