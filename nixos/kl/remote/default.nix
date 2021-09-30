{ config, pkgs, types, lib, ... }:
{
  imports = [
    ./klvpn
  ];
  options.local.kl.remote = {
    enable = lib.mkEnableOption ''
      Is current system is remote accessor to kl domain network.
    '';
  };
  config = {
    local.kl = lib.mkIf config.local.kl.remote.enable {
      enable = true;
    };
  };
}
