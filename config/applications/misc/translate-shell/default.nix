{ config, ... }:
{
  config = {
    programs.translate-shell.enable = config.hardware.isGraphic;
  };
}
