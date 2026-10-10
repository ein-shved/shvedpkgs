{ pkgs, config, ... }:
{
  config = {
    services.pulseaudio = {
      enable = config.hardware.isGraphic;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
  };
}

