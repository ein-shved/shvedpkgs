{ lib, ide-manager, system, ... }:
lib.mkOverlay (
  { ... }:
  {
    inherit (ide-manager.packages.${system}) ide-manager;
  }
)

