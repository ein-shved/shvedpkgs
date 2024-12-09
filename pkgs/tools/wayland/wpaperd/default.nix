{ pkgs-unstable, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      wpaperd = pkgs-unstable.wpaperd;
    })
  ];
}
