{ lib, config, ... }:
{
  options = {
    kl = {
      domain = with lib; {
        enable = mkEnableOption "Enable KL domain services";
        host =  mkOption {
          description = "Address of host inside kl domain if any";
          type = types.nullOr types.str;
          default = config.user.domainName + ".avp.ru";
        };
      };
    };
  };
  config = {
    kl = lib.mkIf config.kl.domain.enable {
      enable = true;
    };
  };
}
