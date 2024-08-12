
{ pkgs, config, ... }:
{
  imports = [
   ./pulseaudio
   ./pipewire
   ./mpv
   ./camera
  ];
  config = {
    documentation.man.generateCaches = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
