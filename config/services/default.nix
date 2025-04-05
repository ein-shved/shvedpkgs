{ ... }:
{
  imports = [
    ./nas
    ./networking
    ./printing
  ];
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
}
