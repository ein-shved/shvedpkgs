{ pkgs, lib, config, ... }:
{
  options = {
    local.kl = {
      domain = with lib; {
        enable = mkEnableOption "Enable KL domain services";
        host =  mkOption {
          description = "Address of host inside kl domain if any";
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
  };
  config = {
    local.kl = lib.mkIf config.local.kl.domain.enable {
      enable = true;
    };
  };
}
