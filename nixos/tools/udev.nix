{ pkgs, lib, config, ... }:
let
  cfg = config.local.udev;
in
{
  options = {
    local.udev = {
      extraRules = with lib; mkOption {
        type = types.listOf types.str;
        description = "The extra rules for udev";
        default = [];
      };
    };
  };
  config = lib.mkIf (cfg.extraRules != []) {
    services.udev.extraRules =
      builtins.foldl' (x: y: x + "\n" + y) "" cfg.extraRules;
  };
}
