{ config, ... }:
{
  config = {
    programs.pass.enable = config.hardware.isGraphic;
  };
}
