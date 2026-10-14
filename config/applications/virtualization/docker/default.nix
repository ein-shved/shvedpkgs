{ config, ... }:
{
  config = {
    virtualisation.docker.enable = config.hardware.isGraphic;
  };
}
