{ pkgs, ... }:
with pkgs;
let
  ide = callPackage ./ide {};
in {
  imports = [
    ./make.nix
    ./python
    ./dhcps
    ./ack.nix
  ];
  config = {
    environment.systemPackages = [
        ide
    ];
    virtualisation.docker.enable = true;
  };
}
