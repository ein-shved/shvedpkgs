{ testers }:
testers.runNixOSTest {
  name = "power-wakeup";
  nodes.machine.hardware.power.wakeOnPowerButtonOnly.enable = true;
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("test -r /proc/acpi/wakeup")
    machine.succeed("systemctl start --wait wakeOnPowerButtonOnly.service")
    machine.wait_until_succeeds("systemctl show wakeOnPowerButtonOnly.service -p Result --value | grep -Fx success")
    machine.fail("grep enabled /proc/acpi/wakeup | grep -v -E 'PBTN|PWRB|platform'")
  '';
}
