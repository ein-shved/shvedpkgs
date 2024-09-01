{ ... }:
{
  imports = [
    ./networking
    ./printing
  ];
  services.power-profiles-daemon.enable = true;
  services.udisks2.enable = true;
}
