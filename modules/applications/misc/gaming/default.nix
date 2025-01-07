{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.environment.gaming;
in
{
  options.environment.gaming.enable = mkEnableOption "this setup is used for gaming";
  config.programs.steam = {
    inherit (cfg) enable;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
  };
  config.boot = mkIf cfg.enable {
    kernelModules = [ "hid-playstation" ];
  };
}
