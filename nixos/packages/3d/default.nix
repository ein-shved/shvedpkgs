{ lib, config, pkgs, ... }:
let
  cfg = config.local.threed;
in
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
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.prusa-slicer
    ];
  };
}
