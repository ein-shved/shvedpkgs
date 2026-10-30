{ testers }:
testers.runNixOSTest {
  name = "printing3d";
  nodes.machine = { config, lib, ... }: {
    imports = [ ../../config/applications/misc/prusa-slicer ];
    user.name = "tester";
    home.enable = true;
    environment.printing3d.enable = true;
    # Exercise local configuration without contacting the personal Git remote.
    services.gitwatch.modeling3d.enable = lib.mkForce false;
    assertions = [
      {
        assertion = config.services.gitwatch.modeling3d.user == "tester"
          && config.services.gitwatch.modeling3d.path == "/home/tester/Projects/3D";
        message = "The modeling repository follows the primary account";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("cmp /home/tester/.config/PrusaSlicer/PrusaSlicer.ini ${../../config/applications/misc/prusa-slicer/PrusaSlicer/PrusaSlicer.ini}")
    machine.succeed("su - tester -c 'test -w ~/.config/PrusaSlicer/PrusaSlicer.ini'")
    machine.succeed("stat -c %U:%a /home/tester/.config/PrusaSlicer/PrusaSlicer.ini | grep -Fx tester:644")
  '';
}
