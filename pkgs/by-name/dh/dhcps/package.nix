{
  replaceVarsWith,
  dnsmasq,
  coreutils,
  iproute2,
  runtimeShell,
}:
replaceVarsWith {
  src = ./dhcps.sh;
  replacements = {
    ip = "${iproute2}/bin/ip";
    dnsmasq = "${dnsmasq}/bin/dnsmasq";
    mkdir = "${coreutils}/bin/mkdir";
    bash = runtimeShell;
  };
  postInstall = ''
    mv $out ./dhcps
    mkdir -p $out/bin/
    mv dhcps $out/bin/
    chmod +x $out/bin/dhcps
  '';
}
