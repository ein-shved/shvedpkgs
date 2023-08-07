{ pkgs, lib, ... }:
let
  splitNameAt = name: index: builtins.elemAt (lib.splitString " " name) index;
in
{
  mkHmExtra = section: value: [{ inherit section value; }];
  mkOverlay = fn: { nixpkgs.overlays = [ (self: super: fn super) ]; };
  getFirstName = name: splitNameAt name 0;
  getSurname = name: splitNameAt name 1;
}
