{ testers }:
testers.runNixOSTest {
  name = "drive-standby";
  nodes.machine = { config, lib, ... }: {
    hardware.drives = {
      "/dev/disabled".standby.enable = false;
      "/dev/vda".standby = {
        enable = true;
        timeout = 240;
      };
    };
    assertions = [
      {
        assertion = lib.hasInfix "hdparm -S 240 /dev/vda"
          config.systemd.services.hard-drive-standby-dev-vda.script;
        message = "The selected drive and timeout reach the standby command";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("hard-drive-standby-dev-vda.timer")
    machine.succeed("systemctl cat hard-drive-standby-dev-vda.timer | grep -Fx OnBootSec=1200")
    machine.succeed("systemctl cat hard-drive-standby-dev-vda.timer | grep -Fx OnUnitActiveSec=1200")
    machine.fail("systemctl cat hard-drive-standby-dev-disabled.service")
    machine.fail("systemctl cat hard-drive-standby-dev-disabled.timer")
  '';
}
