{ config, pkgs, lib, ... }:
{
  networking.firewall.trustedInterfaces = [
    #Allow our containers to interact with host
    "docker0"
  ];
}

