
{ ... }:
{
  imports = [
   ./pulseaudio
   ./pipewire
   ./mpv
   ./camera
  ];
  config = {
    documentation.man.generateCaches = true;
  };
}
