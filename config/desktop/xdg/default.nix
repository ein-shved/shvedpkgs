{ pkgs, ... }:
{
  imports = [
    ./mime
  ];
  config = {
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
