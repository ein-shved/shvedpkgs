{ config, pkgs, lib, ... }:
let
  pyShellNix = ./pyshell.nix;
  pyshell = pkgs.writeShellScriptBin "pyshell" ''
    set -e
    pyshellnix=$(${pkgs.coreutils}/bin/mktemp /tmp/pyshell.XXX.nix)
    cat ${pyShellNix} | sed 's/\#<\-\-pypackages\-\->/'"$*"'/' > "$pyshellnix";
    ${pkgs.nix}/bin/nix-shell "$pyshellnix"
    rm $pyshellnix
  '';
in
{
  config.environment.systemPackages = [ pyshell ];
}
