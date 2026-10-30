{ testers }:
testers.runNixOSTest {
  name = "git-identity";
  nodes.machine = { config, ... }: {
    imports = [ ../../config/applications/version-management/git ];
    user = {
      name = "tester";
      humanName = "Alice Example";
    };
    home.enable = true;
    kl.domain.enable = true;
    assertions = [
      {
        assertion = config.user.domainName == "example"
          && config.kl.domain.hostname == "example"
          && config.kl.domain.host == "example.avp.ru";
        message = "KL domain identity uses the primary user's surname";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("su - tester -c 'git config --get user.name' | grep -Fx 'Alice Example'")
    machine.succeed("su - tester -c 'git config --get user.email' | grep -Fx alice.example@kaspersky.com")
  '';
}
