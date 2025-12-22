{ lib, config, ... }:
let
  cfg = config.user;
in
{
  options = {
    environment.systemPackages = lib.mkOption {
      type = with lib.types; listOf anything;
      default = [ ];
    };
    environment.variables = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = [ ];
    };
    home.programs = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = [ ];
    };
    home.xdg = lib.mkOption {
      type = with lib.types; attrsOf anything;
      default = [ ];
    };

    user = {
      name = lib.mkOption {
        description = "Default user login string";
        type = lib.types.str;
      };

      humanName = lib.mkOption {
        description = "Introduce yourself";
        type = lib.types.str;
        default = cfg.name;
      };

      home = lib.mkOption {
        description = "Homedir";
        type = lib.types.str;
        default = "/home/${cfg.name}";
      };

      mail = lib.mkOption {
        description = "User e-mail";
        type = with lib.types; nullOr str;
        default = null;
      };

    };

    programs.bash.completion.enable = lib.mkEnableOption "bash completion";
  };

  config = {
    home.packages = config.environment.systemPackages;
    home.sessionVariables = config.environment.variables;
    home.username = cfg.name;
    home.homeDirectory = cfg.home;
    programs = config.home.programs;
    xdg = config.home.xdg;
  };
}
