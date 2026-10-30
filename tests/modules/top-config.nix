{ testers }:
testers.runNixOSTest {
  name = "top-config";
  nodes.machine = {
    imports = [ ../../config/tools/system/top ];
    user.name = "tester";
    home.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("cmp /home/tester/.toprc ${../../config/tools/system/top/toprc}")
  '';
}
