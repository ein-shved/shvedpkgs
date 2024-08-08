{ lib, ... }:
lib.mkOverlay (
  { callPackage, ... }:
  {
    rtpkcs11ecp = callPackage ./rtpkcs11ecp.nix { };
  }
)

