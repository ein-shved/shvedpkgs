{ config, ... }:
{
  config.services = {
    printing.enable = config.hardware.needGraphic;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
