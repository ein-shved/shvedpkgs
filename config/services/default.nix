{ ... }:
{
  imports = [
    ./networking
    ./printing
  ];
  services.power-profiles-daemon.enable = true;
}
