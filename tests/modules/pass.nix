{ testers }:
testers.runNixOSTest {
  name = "pass";
  nodes.machine = { config, ... }: {
    user.name = "tester";
    programs.pass.enable = true;
    assertions = [
      {
        assertion = config.programs.gnupg.agent.enable && !config.home.enable;
        message = "The pass feature enables GPG agent integration without requiring HM";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("su - tester -c 'pass otp --help' | grep -F 'pass otp'")
  '';
}
