{ testers }:
testers.runNixOSTest {
  name = "home-manager-merge";
  nodes.machine = { config, lib, ... }: {
    user.name = "tester";
    home.enable = true;
    hm.home = {
      sessionPath = lib.mkBefore [ "/before" ];
      file = {
        merged.text = lib.mkBefore "alias";
        alias-default.text = lib.mkDefault "alias";
        direct-default.text = "alias";
        direct-force.text = "alias";
      };
    };
    home-manager.users.tester.home = {
      sessionPath = lib.mkAfter [ "/after" ];
      file = {
        merged.text = lib.mkAfter "direct";
        alias-default.text = "direct";
        direct-default.text = lib.mkDefault "direct";
        direct-force.text = lib.mkForce "direct";
      };
    };
    assertions = [
      {
        assertion = config.hm.home.sessionPath == [ "/before" "/after" ];
        message = "HM alias preserves ordering when merged with direct declarations";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    assert machine.succeed("cat /home/tester/merged").splitlines() == ["alias", "direct"]
    machine.succeed("grep -Fx direct /home/tester/alias-default")
    machine.succeed("grep -Fx alias /home/tester/direct-default")
    machine.succeed("grep -Fx direct /home/tester/direct-force")
  '';
}
