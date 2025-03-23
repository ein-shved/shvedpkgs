{ pkgs, config, ... }:
{
  config = {
    hardware.pulseaudio = {
      enable = config.hardware.needGraphic;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
  };
}

