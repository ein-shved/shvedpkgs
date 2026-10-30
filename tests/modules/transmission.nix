{ testers }:
testers.runNixOSTest {
  name = "transmission";
  nodes.machine = {
    imports = [ ../../config/applications/networking/p2p/transmission ];
    user.name = "tester";
    home.enable = true;
  };
  testScript = ''
    import json
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.wait_for_unit("transmission.service")
    machine.wait_for_open_port(9091)
    machine.succeed("stat -c %U:%G:%a /home/tester/.config/transmission-daemon | grep -Fx tester:transmission:700")
    machine.succeed("stat -c %U:%G:%a /home/tester/Downloads | grep -Fx tester:transmission:770")
    assert "home-manager-tester.service" in machine.succeed("systemctl show transmission.service -p After --value").split()
    settings = json.loads(machine.succeed("cat /home/tester/.config/transmission-daemon/settings.json"))
    assert settings["download-dir"] == "/home/tester/Downloads"
    assert settings["rpc-bind-address"] == "127.0.0.1"
  '';
}
