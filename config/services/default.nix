{ config, lib, ... }:
{
  services.gerrit.enable = lib.mkDefault config.hardware.isVps;
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.speechd.enable = false;
}
