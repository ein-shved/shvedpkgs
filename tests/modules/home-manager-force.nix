{ testers }:
testers.runNixOSTest {
  name = "home-manager-force";
  nodes.machine = { config, lib, ... }: {
    user.name = "tester";
    home.enable = true;
    hm = lib.mkForce {
      home.stateVersion = config.system.stateVersion;
      home.file.priority.text = "alias";
    };
    home-manager.users.tester.home.file.priority.text = "direct";
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("grep -Fx alias /home/tester/priority")
  '';
}
