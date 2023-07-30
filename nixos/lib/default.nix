{ pkgs, lib, ... }:
{
  mkHmExtra = section: value: [{ inherit section value; }];
  mkOverlay = fn: { nixpkgs.overlays = [ (self: super: fn super) ]; };
}
