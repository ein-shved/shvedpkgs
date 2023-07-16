{ config, pkgs, ... }:
{
  imports = [
    ./allowance.nix
    ./home
    ./desktop
    ./media
  ];
}
