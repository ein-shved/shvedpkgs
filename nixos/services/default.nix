{ config, pkgs, lib, ... }:
{
  imports = [
    ./transmission.nix
    ./power.nix
    ./git.nix
    ./ssh.nix
    ./top.nix
    ./firewall.nix
    ./openvpn.nix
  ];
  config = {
    services = {
      printing.enable = true;
      blueman.enable = config.local.bluetooth;
      openssh = {
        enable = true;
      };
    };
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = config.local.bluetooth;
  };
  options = {
    local = {
      bluetooth = lib.mkEnableOption "Bluetooth";
    };
  };
}
