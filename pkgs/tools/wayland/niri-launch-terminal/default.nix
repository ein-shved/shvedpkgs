{ lib, ... }:
lib.mkOverlay (
  { callPackage, ... }:
  {
    niri-launch-terminal = callPackage ./package.nix { };
  }
)

