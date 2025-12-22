root:
{ path, ... }:
let
  by-name-overlay = import "${path}/pkgs/top-level/by-name-overlay.nix";
in
{
  nixpkgs.overlays = [
    (
      final: prev:
      (
        if (!(prev ? pkgsOrigin)) then
          {
            pkgsOrigin = prev;
          }
        else
          { }
      )
      // (by-name-overlay root final prev)
    )
  ];
}
