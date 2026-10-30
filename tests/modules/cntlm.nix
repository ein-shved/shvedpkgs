{ testers }:
testers.runNixOSTest {
  name = "cntlm";
  nodes.machine = {
    user.name = "tester";
    services.cntlm-gss = {
      enable = true;
      proxy = [ "127.0.0.1:3129" ];
    };
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("cntlm-gss.service")
    machine.wait_for_open_port(3128)
    machine.succeed("systemctl show cntlm-gss.service -p User --value | grep -Fx tester")
  '';
}
