{ lib, config, pkgs, ... }:
let
  cfg = config.programs.firefox;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.firefox
    ];
  };
  options = {
    programs.firefox = {
      enable = lib.mkEnableOption "Use firefox withing system";
    };
  };
}
