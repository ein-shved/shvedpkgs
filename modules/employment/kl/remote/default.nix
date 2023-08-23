{ config, lib, pkgs, ... }:
let
  cfg = config.kl.remote;
in
{
  options = {
    kl.remote = {
      enable = lib.mkEnableOption ''
        Is current system is remote accessor to kl domain network.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    kl.enable = true;
    services.klvpn.enable = true;
  };
}

