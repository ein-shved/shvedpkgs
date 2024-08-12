{ lib, ... }:
lib.mkOverlay (
  { callPackage, ... }:
  {
    # TODO(Shvedov) Remove this after switching to nixpkgs with
    # hyprland-per-window-layout version >= 2.12
    hyprland-per-window-layout = callPackage ./hyprland-per-window-layout.nix { };
  }
)

