{ testers }:
testers.runNixOSTest {
  name = "primary-user-customization";
  nodes.machine = { config, ... }: {
    user = {
      name = "tester";
      humanName = "Alice Cooper";
      home = "/srv/tester";
      password = "test-only";
      mail = "alice@example.invalid";
      extraGroups = [ "test-group" ];
      domainNameMaker = name: "custom-${name}";
    };
    users.groups.test-group = { };
    assertions = [
      {
        assertion = config.user.domainName == "custom-Alice Cooper"
          && config.user.mail == "alice@example.invalid"
          && config.users.users.tester.password == "test-only";
        message = "Primary account forwards custom metadata and uses the supplied domain-name factory";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("getent passwd tester | cut -d: -f5-6 | grep -Fx 'Alice Cooper:/srv/tester'")
    machine.succeed("test -d /srv/tester && test $(stat -c %U /srv/tester) = tester")
    machine.succeed("id -nG tester | tr ' ' '\\n' | grep -Fx test-group")
  '';
}
