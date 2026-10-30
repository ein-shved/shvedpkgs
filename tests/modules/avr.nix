{ testers }:
testers.runNixOSTest {
  name = "avr";
  nodes.machine.hardware.programmers.avr.enable = true;
  testScript = ''
    start_all()
    machine.wait_for_unit("systemd-udevd.service")
    machine.succeed("grep -E 'idVendor.*16c0' /etc/udev/rules.d/99-local.rules")
    machine.succeed("grep -E 'idProduct.*05dc' /etc/udev/rules.d/99-local.rules")
    machine.succeed("grep -E 'GROUP=.dialout.' /etc/udev/rules.d/99-local.rules")
  '';
}
