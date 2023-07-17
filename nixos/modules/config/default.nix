{ config, pkgs, ... }:
{
  imports = [
    ./allowance.nix
    ./applications
    ./bashrc
    ./desktop
    ./media
  ];
}
