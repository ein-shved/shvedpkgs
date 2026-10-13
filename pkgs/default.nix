{ lib, flake-inputs, ... }:
{
  imports = [
    (lib.mkBynameOverlayModule ./by-name)
  ];

  nixpkgs.overlays = [
    (final: prev: {
      pkgsUnstable = import flake-inputs.unstable {
        system = final.stdenv.hostPlatform.system;
      };
    })
  ];
}
