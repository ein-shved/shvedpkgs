{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.guake
  ];
}
