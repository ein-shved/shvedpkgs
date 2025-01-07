{ path, ... }:
let
  by-name-overlay = import "${path}/pkgs/top-level/by-name-overlay.nix" ./by-name;
in
{
  nixpkgs.overlays = [ by-name-overlay ];
}
