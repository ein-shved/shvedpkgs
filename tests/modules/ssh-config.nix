{ testers }:
testers.runNixOSTest {
  name = "ssh-config";
  nodes.machine = {
    imports = [ ../../config/services/networking/ssh.nix ];
    user.name = "tester";
    home.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("sshd.service")
    machine.wait_for_unit("home-manager-tester.service")
    server_settings = machine.succeed("sshd -T -f /etc/ssh/sshd_config").lower().splitlines()
    assert "x11forwarding yes" in server_settings, server_settings
    settings = machine.succeed("su - tester -c 'ssh -G example.invalid'").lower().splitlines()
    assert "serveraliveinterval 10" in settings, settings
    assert "serveralivecountmax 3" in settings, settings
    assert "forwardagent no" in settings, settings
    assert "controlmaster false" in settings, settings
  '';
}
