{ lib, ... }:
{
  imports = [
    ./data
    ./development
    ./os-specific
    ./tools
    (lib.mkBynameOverlayModule ./by-name)
  ];
}
