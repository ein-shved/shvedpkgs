{ lib, ... }:
lib.mkOverlay (
  { callPackage, ... }:
  {
    pcsc-safenet-legacy = callPackage ./pcsc-safenet-legacy.nix { };
  }
)
