{ lib, config, pkgs, ... }:
let
  cfg = config.environment.printing3d;
in
{
  options.environment.printing3d = {
    enable = lib.mkEnableOption ''
      Is current system used for 3D modelling and printing
    '';
  };
  config = lib.mkIf cfg.enable {
    services.hasplmd.enable = true;
    environment.systemPackages = [
      pkgs.prusa-slicer
    ];
  };
}

