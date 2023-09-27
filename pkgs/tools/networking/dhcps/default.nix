{ lib, ... }:
lib.mkOverlay (
  { substituteAll
  , dnsmasq
  , coreutils
  , iproute2
  , runtimeShell
  , runCommandLocal
  , ...
  }:
  let
    dhcps_sh = substituteAll {
      src = ./dhcps.sh;
      ip = "${iproute2}/bin/ip";
      dnsmasq = "${dnsmasq}/bin/dnsmasq";
      mkdir = "${coreutils}/bin/mkdir";
      bash = runtimeShell;
      postInstall = "chmod +x $out";
    };
  in
  {
    dhcps = runCommandLocal "dhcps" { dhcps = dhcps_sh; } ''
      mkdir -p $out/bin
      ln -s $dhcps $out/bin/dhcps
    '';
  }
)
