{ lib, ... }:
{
  imports = [
    (lib.mkBynameOverlayModule ./by-name)
  ];
}
