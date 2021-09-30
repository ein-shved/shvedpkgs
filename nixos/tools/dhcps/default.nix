{ config, pkgs, lib, ... }:
let
  dhcps_sh = pkgs.substituteAll {
    src = ./dhcps.sh;
    ip = "${pkgs.iproute2}/bin/ip";
    dnsmasq = "${pkgs.dnsmasq}/bin/dnsmasq";
    mkdir = "${pkgs.coreutils}/bin/mkdir";
    bash = pkgs.runtimeShell;
    postInstall = "chmod +x $out";
  };
  dhcps = pkgs.runCommandLocal "dhcps" {dhcps = dhcps_sh;} ''
    mkdir -p $out/bin
    ln -s $dhcps $out/bin/dhcps
  '';
in
{
  config.environment.systemPackages = [
      dhcps
  ];
}
