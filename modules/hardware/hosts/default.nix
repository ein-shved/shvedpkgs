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
      needGraphic = lib.mkOption {
        description = ''
          Whenether this host does not need graphics.
        '';
        default = true;
        type = lib.types.bool;
      };
      development = lib.mkOption {
        description = ''
          Whenether this host is used for development.
        '';
        default = true;
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
    };
  };

  config = {
    nixpkgs.overlays = [
      (final: prev: {
        isLaptop = config.hardware.isLaptop;
        isNas = config.hardware.isNas;
        isDesktop = (!final.isLaptop) && (!final.isNas);
      })
    ];
    environment.systemPackages =
      lib.optionals config.hardware.needGraphic config.environment.graphicPackages
      ++ lib.optionals config.hardware.needGraphic config.environment.developmentPackages
      ++ lib.optionals config.hardware.isNas config.environment.nasPackages;
    hardware = lib.mkIf config.hardware.isNas {
      needGraphic = false;
      development = false;
    };
  };
}
