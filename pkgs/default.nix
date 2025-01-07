{ ... }:
{
  imports = [
    ./applications
    ./by-name-overlay.nix
    ./data
    ./development
    ./os-specific
    ./tools
  ];
}
