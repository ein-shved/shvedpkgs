{ lib, pkgsUnstable, ... }:
{
  imports = [
    (lib.mkBynameOverlayModule ./by-name)
  ];

  nixpkgs.overlays = [
    (final: prev: { inherit pkgsUnstable; })
  ];
}
