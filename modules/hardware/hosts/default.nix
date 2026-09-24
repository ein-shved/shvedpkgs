{ lib, config, ... }:
{
  options = {
    hardware = {
      isLaptop = lib.mkOption {
        description = ''
          Whenether this host is laptop.
        '';
        default = false;
        type = lib.types.bool;
      };
      isNas = lib.mkOption {
        description = ''
          Whenether this host is nas server.
        '';
        default = false;
        type = lib.types.bool;
      };
      isVps = lib.mkOption {
        description = ''
          Whenether this host is vps server.
        '';
        default = false;
        type = lib.types.bool;
      };
      isVpsClient = lib.mkOption {
        description = ''
          Whenether this host is attendend to interract with vps.
        '';
        default = false;
        type = lib.types.bool;
      };
      needGraphic = lib.mkOption {
        description = ''
          Whenether this host does not need graphics.
        '';
        default = false;
        type = lib.types.bool;
      };
      development = lib.mkOption {
        description = ''
          Whenether this host is used for development.
        '';
        default = false;
        type = lib.types.bool;
      };
    };

    environment = {
      graphicPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `haedware.needGraphic` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      developmentPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `haedware.development` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      nasPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `haedware.isNas` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      vpsPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `haedware.isVps` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        isLaptop = config.hardware.isLaptop;
        isNas = config.hardware.isNas;
        isVps = config.hardware.isVps;
        isVpsClient = config.hardware.isVpsClient;
      })
    ];
    environment.systemPackages =
      lib.optionals config.hardware.needGraphic config.environment.graphicPackages
      ++ lib.optionals config.hardware.development config.environment.developmentPackages
      ++ lib.optionals config.hardware.isNas config.environment.nasPackages
      ++ lib.optionals config.hardware.isVps config.environment.vpsPackages;
  };
}
