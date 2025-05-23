{ lib, ... }:
{
  imports = [
    ./applications
    ./data
    ./development
    ./os-specific
    ./tools
    (lib.mkBynameOverlayModule ./by-name)
  ];
}
