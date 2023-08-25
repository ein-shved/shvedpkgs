{ pkgs, lib, ... }:
let
  splitNameAt = name: index: let
    splitted = lib.splitString " " name;
    hasIndex = index < builtins.length splitted;
  in
    if hasIndex
      then builtins.elemAt splitted index
      else "";
in
{
  mkHmExtra = section: value: [{ inherit section value; }];
  mkOverlay = fn: { nixpkgs.overlays = [ (self: super: fn super) ]; };
  getFirstName = name: splitNameAt name 0;
  getSurname = name: splitNameAt name 1;
}
