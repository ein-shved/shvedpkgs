{ lib, ... }:
lib.mkOverlay (
  pkgs:
  {
    aff4 = pkgs.callPackage ./aff4.nix { };
  }
)
