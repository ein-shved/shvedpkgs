{ config, lib, ... }:
{
  services.gerrit.enable = lib.mkDefault config.hardware.isVps;
  services.journald.extraConfig = lib.mkIf config.hardware.isVps ''
    SystemMaxUse=100M
  '';
  services.power-profiles-daemon.enable = config.hardware.isGraphic;
  services.udisks2.enable = config.hardware.isGraphic;
  services.upower.enable = config.hardware.isGraphic;
  services.speechd.enable = false;
}
