{ testers }:
testers.runNixOSTest {
  name = "home-manager-inactive";
  nodes.machine = { options, ... }: {
    user.name = "tester";
    home.enable = false;
    home.refresh-profile.enable = true;
    hm = {
      imports = [ (_: throw "inactive HM module body was applied") ];
      home.file.unused.text = throw "inactive HM value was evaluated";
      programs.git.enable = "invalid while inactive";
    };
    assertions = [
      {
        assertion = options.hm.type.name == "deferredModule";
        message = "The HM declaration type remains available while inactive";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("getent passwd tester")
    machine.fail("systemctl cat home-manager-tester.service")
    machine.succeed("test ! -e /home/tester/unused")
  '';
}
