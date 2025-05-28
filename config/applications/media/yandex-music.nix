{ pkgs, ... }:
{
  environment.graphicPackages = with pkgs; [
    (yandex-music.override {
      trayEnabled = true;
      trayStyle = 3;
      trayAlways = true;
      vibeAnimationMaxFps = 0;
    })
  ];
}
