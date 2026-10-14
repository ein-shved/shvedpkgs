{
  lib,
  config,
  ...
}:
let
  inherit (config.hardware) isGraphic;
  in
{
  services = lib.mkIf isGraphic {
    displayManager.lemurs.enable = true;
    xserver.displayManager.lightdm.enable = false;
  };
}
