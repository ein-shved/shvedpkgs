{ config, pkgs, ... }:
{
  imports = [
    ./allowance.nix
    ./bashrc
    ./desktop
    ./media
  ];
}
