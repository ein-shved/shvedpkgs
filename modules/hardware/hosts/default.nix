{ lib, config, ... }:
{
  options.hardware.isLaptop = lib.mkOption {
    description = ''
      Whenether this host is laptop.
    '';
    default = false;
    type = lib.types.bool;
  };
  options.hardware.needGraphic = lib.mkOption {
    description = ''
      Whenether this host does not need graphics.
    '';
    default = true;
    type = lib.types.bool;
  };
  options.hardware.development = lib.mkOption {
    description = ''
      Whenether this host is used for development.
    '';
    default = true;
    type = lib.types.bool;
  };
  options.environment.graphicPackages = lib.mkOption {
    description = ''
      Set of packages which enabled only when `haedware.needGraphic` is enabled
    '';
    default = [ ];
    type = lib.types.listOf lib.types.package;
  };
  options.environment.developmentPackages = lib.mkOption {
    description = ''
      Set of packages which enabled only when `haedware.development` is enabled
    '';
    default = [ ];
    type = lib.types.listOf lib.types.package;
  };
  config.nixpkgs.overlays = [
    (_: _: {
      isLaptop = config.hardware.isLaptop;
      isDesktop = !config.hardware.isLaptop;
    })
  ];
  config.environment.systemPackages =
    lib.optionals config.hardware.needGraphic config.environment.graphicPackages
    ++ lib.optionals config.hardware.needGraphic config.environment.developmentPackages;
}
