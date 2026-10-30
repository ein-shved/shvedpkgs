{ testers }:
testers.runNixOSTest {
  name = "home-manager-independent-primary";
  nodes.machine = { config, ... }: {
    user.name = "tester";
    home-manager.users.tester.home = {
      stateVersion = config.system.stateVersion;
      file.independent.text = "direct";
    };
    hm.home.file.unused.text = throw "inactive primary alias was consumed by direct HM";
    assertions = [
      {
        assertion = !config.home.enable && !config.home-manager.useGlobalPkgs;
        message = "A direct HM user does not activate the primary alias";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("su - tester -c 'grep -Fx direct ~/independent && test ! -e ~/unused'")
  '';
}
