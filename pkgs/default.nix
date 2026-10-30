{ lib, extensions, ... }:
{
  imports = [
    (lib.mkBynameOverlayModule ./by-name)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      inherit lib extensions;
      inherit (extensions) flake-inputs pkgsUnstable;
    })
  ];
}
