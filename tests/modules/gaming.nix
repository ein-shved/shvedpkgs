{ testers }:
testers.runNixOSTest {
  name = "gaming";
  nodes.machine = { config, ... }: {
    environment.gaming.enable = true;
    assertions = [
      {
        assertion = config.programs.steam.enable
          && config.programs.steam.extest.enable
          && config.programs.steam.remotePlay.openFirewall
          && config.programs.steam.dedicatedServer.openFirewall
          && config.programs.steam.localNetworkGameTransfers.openFirewall;
        message = "Gaming enables Steam with the project's input and networking defaults";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("systemd-modules-load.service")
    machine.wait_for_unit("firewall.service")
    machine.succeed("test -d /sys/module/hid_playstation")
    machine.succeed("test -x /run/current-system/sw/bin/steam")
    firewall = machine.succeed("iptables -S nixos-fw")
    for port in [27015, 27036, 27037, 27040]:
        assert f"--dport {port} " in firewall
  '';
}
