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
      isGraphic = lib.mkOption {
        description = ''
          Whenether this host does not need graphics.
        '';
        default = false;
        type = lib.types.bool;
      };
      isDevelopment = lib.mkOption {
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
          Set of packages which enabled only when `hardware.isGraphic` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      developmentPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `hardware.isDevelopment` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      laptopPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `hardware.isLaptop` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      nasPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `hardware.isNas` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      vpsPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `hardware.isVps` is enabled
        '';
        default = [ ];
        type = lib.types.listOf lib.types.package;
      };
      vpsClientPackages = lib.mkOption {
        description = ''
          Set of packages which enabled only when `hardware.isVpsClient` is enabled
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
        isGraphic = config.hardware.isGraphic;
        isDevelopment = config.hardware.isDevelopment;
        isNas = config.hardware.isNas;
        isVps = config.hardware.isVps;
        isVpsClient = config.hardware.isVpsClient;
      })
    ];
    environment.systemPackages =
      lib.optionals config.hardware.isGraphic config.environment.graphicPackages
      ++ lib.optionals config.hardware.isLaptop config.environment.laptopPackages
      ++ lib.optionals config.hardware.isDevelopment config.environment.developmentPackages
      ++ lib.optionals config.hardware.isNas config.environment.nasPackages
      ++ lib.optionals config.hardware.isVps config.environment.vpsPackages
      ++ lib.optionals config.hardware.isVpsClient config.environment.vpsClientPackages;
  };
}
