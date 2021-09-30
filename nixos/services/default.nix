{ config, pkgs, ... }:
{
  imports = [
    ./transmission.nix
    ./power.nix
    ./git.nix
    ./ssh.nix
    ./top.nix
  ];
  config = {
    services = {
      printing.enable = true;
      blueman.enable = true;
      openssh = {
        enable = true;
      };
    };
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
  };
}
