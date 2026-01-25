{ lib, config, ... }:
let
  cfg = config.services.vps;
in
{
  options = {
    services.vps = {
      domain = lib.mkOption {
        description = ''
          Domain name of VPS
        '';
        type = lib.types.str;
      };
      mail = lib.mkOption {
        description = ''
          Mail of admin of vps
        '';
        type = lib.types.str;
        default = "admin@${cfg.domain}";
        defaultText = "admin@<services.vps.domain>";
      };
    };
  };
}
