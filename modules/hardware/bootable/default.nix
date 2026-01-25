{
  flake-inputs,
  lib,
  ...
}:
let
  formats = lib.mapAttrsToList (fname: _: lib.removeSuffix ".nix" fname) (
    builtins.readDir "${flake-inputs.nixos-generators}/formats"
  );
in
{
  formatConfigs = lib.genAttrs formats (
    _:
    { modulesPath, pkgs, ... }:
    {
      imports = [ "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.supportedFilesystems = lib.mkForce [
        "btrfs"
        "reiserfs"
        "vfat"
        "f2fs"
        "xfs"
        "ntfs"
        "cifs"
      ];
    }
  );
}
