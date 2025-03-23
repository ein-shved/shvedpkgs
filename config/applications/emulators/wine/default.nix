{ pkgs, ... }:
{
  config = {
    environment.graphicPackages = with pkgs; [
      wineWowPackages.stable
      winetricks
    ];
  };
}
