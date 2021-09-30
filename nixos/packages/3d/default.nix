{ lib, config, pkgs, ... }:
{
  options.local.threed = {
    enable = lib.mkEnableOption ''
      Is current system used for 3D modelling and printing
    '';
  };
  imports = [
    ./cura
    ./nvidia
  ];
}
