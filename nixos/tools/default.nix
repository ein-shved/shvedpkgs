{ pkgs, ... }:
with pkgs;
let
  ide = callPackage ./ide {};
in {
  imports = [
    ./make.nix
    ./python
    ./dhcps
  ];
  config = {
    environment.systemPackages = [
        ide
    ];
    virtualisation.docker.enable = true;
  };
}
