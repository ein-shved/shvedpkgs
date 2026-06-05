{
  lib,
  config,
  ...
}:
let
  inherit (config.hardware) needGraphic;
  in
{
  services = lib.mkIf needGraphic {
    displayManager.lemurs.enable = true;
    xserver.displayManager.lightdm.enable = false;
  };
}
