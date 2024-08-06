{ lib, config, ... }:
{
  options.hardware.isLaptop = lib.mkOption {
    description = ''
      Whenether this host is laptop.
    '';
    default = false;
    type = lib.types.bool;
  };
  config.nixpkgs.overlays = [
    (_: _: {
        isLaptop = config.hardware.isLaptop;
        isDesktop = ! config.hardware.isLaptop;
    })
  ];
}
