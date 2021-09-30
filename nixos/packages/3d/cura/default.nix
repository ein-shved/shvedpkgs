{ lib, config, pkgs, ... }:
let
  cura = pkgs.cura.override { plugins = [ pkgs.curaPlugins.octoprint ]; };
  cfg = config.local.threed;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cura
    ];
  };
}

