{ config, lib, ... }:
let
  cfg = config.kl;
in
{
  options = {
    kl = {
      enable = lib.mkEnableOption ''
        Is current system used by Kaspersy Lab employee.
      '';
      mail = lib.mkOption {
        type = lib.types.str;
        description = "Internal KL employee e-mail.";
        default = (lib.toLower (builtins.replaceStrings [ " " ] [ "." ]
          config.user.humanName)) + "@kaspersky.com";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    user.mail = cfg.mail;
  };
}
