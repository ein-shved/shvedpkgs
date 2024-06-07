{ lib, ... }:
lib.mkOverlay (
  pkgs:
  {
    ripgrep = pkgs.callPackage ./ripgrep-configurable.nix {
      ripgrepPkg = pkgs.ripgrep;
    };
  }
)

