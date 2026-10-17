{ lib, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.environment.gaming;
in
{
  options.environment.gaming.enable = mkEnableOption "this setup is used for gaming";
  config.programs.steam = lib.mkMerge [
    { enable = lib.mkDefault cfg.enable; }
    (mkIf (cfg.enable && config.programs.steam.enable) {
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extest.enable = true;
    })
  ];
  config.boot = mkIf cfg.enable {
    kernelModules = [ "hid-playstation" ];
  };
}
