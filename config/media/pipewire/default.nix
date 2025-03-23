{ config, ... }:
{
  services.pipewire = {
    enable = config.hardware.needGraphic;
    # TODO(Shvedov): Switch to pipewire fully
    audio.enable = false;
    pulse.enable = false;
    alsa.enable = false;
  };
}
