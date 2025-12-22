path:
let
  by-name-overlay = import "${path}/pkgs/top-level/by-name-overlay.nix";
in
final: prev:
(
  if (!(prev ? pkgsOrigin)) then
    {
      pkgsOrigin = prev;
    }
  else
    { }
)
// (by-name-overlay ./by-name final prev)
