{ testers }:
testers.runNixOSTest {
  name = "home-manager-default";
  nodes.machine = { lib, ... }: {
    user.name = "tester";
    home.enable = true;
    hm = lib.mkDefault { home.file.priority.text = "alias"; };
    home-manager.users.tester.home.file.priority.text = "direct";
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("grep -Fx direct /home/tester/priority")
  '';
}
