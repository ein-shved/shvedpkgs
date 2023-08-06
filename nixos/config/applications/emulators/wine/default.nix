{ pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [
      wineWowPackages.stable
      winetricks
    ];
  };
}
