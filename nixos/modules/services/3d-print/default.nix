{ config, ... }:
{
  imports = [
    ./hasp.nix
  ];
  config = {
    services.hasplmd.enable = config.local.threed.enable;
  };
}
