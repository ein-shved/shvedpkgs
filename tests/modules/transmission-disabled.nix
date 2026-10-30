{ testers }:
testers.runNixOSTest {
  name = "transmission-disabled";
  nodes.machine = { config, ... }: {
    imports = [ ../../config/applications/networking/p2p/transmission ];
    user.name = "tester";
    home.enable = true;
    services.transmission.enable = false;
    assertions = [
      {
        assertion = !(config.hm.home.activation ? transmission-daemon);
        message = "Explicitly disabled Transmission contributes no home activation";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.fail("systemctl cat transmission.service")
    machine.succeed("test ! -d /home/tester/.config/transmission-daemon")
  '';
}
