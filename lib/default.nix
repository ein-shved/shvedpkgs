{ lib, path, flake-inputs }:
let
  splitNameAt =
    name: index:
    let
      splitted = lib.splitString " " name;
      hasIndex = index < builtins.length splitted;
    in
    if hasIndex then builtins.elemAt splitted index else "";
in
{
  hm = flake-inputs.home-manager.lib.hm;
  mkHmExtra = section: value: [ { inherit section value; } ];
  mkOverlay = fn: { nixpkgs.overlays = [ (self: super: fn super) ]; };
  mkOverlaySelf = fn: { nixpkgs.overlays = [ (self: super: fn self) ]; };
  getFirstName = name: splitNameAt name 0;
  getSurname = name: splitNameAt name 1;
  mkBynameOverlayModule =
    root:
    let
      by-name-overlay = import "${path}/pkgs/top-level/by-name-overlay.nix";
    in
    {
      nixpkgs.overlays = [
        (
          final: prev:
          (lib.optionalAttrs (!(prev ? pkgsOrigin)) {
            pkgsOrigin = prev;
          })
          // (by-name-overlay root final prev)
        )
      ];
    };
}
