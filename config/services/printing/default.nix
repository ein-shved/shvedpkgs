{ config, ... }:
{
  config.services = {
    printing.enable = config.hardware.isGraphic;
    avahi = {
      enable = config.hardware.isGraphic;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
