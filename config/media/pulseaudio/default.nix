{ pkgs, config, ... }:
{
  config = {
    services.pulseaudio = {
      enable = config.hardware.needGraphic;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
  };
}

