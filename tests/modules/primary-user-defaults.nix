{ testers }:
testers.runNixOSTest {
  name = "primary-user-defaults";
  nodes.machine = { config, lib, options, ... }: {
    user.name = "tester";
    assertions = [
      {
        assertion = config.user.domainName == ""
          && config.user.mail == null
          && config.users.users.tester.password == null
          && !(options.user ? enable)
          && lib.all (group: builtins.elem group config.users.users.tester.extraGroups) [
            "wheel" "tty" "dialout" "keys" "audio" "adbusers" "docker" "input" "nixbld"
          ];
        message = "Primary account keeps its default metadata and supplementary groups";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("getent passwd tester | cut -d: -f5-6 | grep -Fx 'tester:/home/tester'")
    machine.succeed("test -d /home/tester && test $(stat -c %U /home/tester) = tester")
    machine.succeed("id -nG tester | tr ' ' '\\n' | grep -Fx wheel")
    assert int(machine.succeed("id -u tester")) >= 1000
  '';
}
