{ mkBynameOverlayModule, ... }:
{
  imports = [
    (mkBynameOverlayModule ./by-name)
  ];
}
