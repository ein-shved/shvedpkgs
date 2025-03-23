{ config, ... }:
{
  config = {
    virtualisation.docker.enable = config.hardware.needGraphic;
  };
}
