{ config, ... }:
{
  config.services = {
    printing.enable = config.hardware.isGraphic;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
