{ testers }:
testers.runNixOSTest {
  name = "stm32";
  nodes.machine.hardware.programmers.stm32.enable = true;
  testScript = ''
    start_all()
    machine.wait_for_unit("systemd-udevd.service")
    machine.succeed("command -v st-info")
    machine.succeed("st-gpio help | grep -F 'Usage:'")
    machine.succeed("grep -E 'idVendor.*0483' /etc/udev/rules.d/99-local.rules")
    machine.succeed("grep -F stlinkv3_%n /etc/udev/rules.d/99-local.rules")
    machine.succeed("grep -F bmonster_control /etc/udev/rules.d/99-local.rules")
  '';
}
