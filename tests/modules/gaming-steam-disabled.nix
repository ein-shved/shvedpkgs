{ testers }:
testers.runNixOSTest {
  name = "gaming-steam-disabled";
  nodes.machine = { config, ... }: {
    environment.gaming.enable = true;
    programs.steam.enable = false;
    assertions = [
      {
        assertion = !config.programs.steam.extest.enable
          && !config.programs.steam.remotePlay.openFirewall
          && !config.programs.steam.dedicatedServer.openFirewall
          && !config.programs.steam.localNetworkGameTransfers.openFirewall;
        message = "Explicitly disabling Steam suppresses its gaming extras";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("systemd-modules-load.service")
    machine.succeed("test -d /sys/module/hid_playstation")
    machine.fail("test -e /run/current-system/sw/bin/steam")
  '';
}
