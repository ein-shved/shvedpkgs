{ ... }:
{
  services.pipewire = {
    enable = true;
    # TODO(Shvedov): Switch to pipewire fully
    audio.enable = false;
    pulse.enable = false;
    alsa.enable = false;
  };
}
