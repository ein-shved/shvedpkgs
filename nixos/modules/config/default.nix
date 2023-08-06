{ config, ... }:
{
  imports = [
    ./allowance.nix
    ./applications
    ./bashrc
    ./desktop
    ./media
    ./tools
    ./services
  ];
  config = {
    services = {
      printing.enable = true;
      blueman.enable = config.hardware.bluetooth.enable;
      openssh = {
        enable = true;
      };
    };
    networking.networkmanager.enable = true;
  };
}
