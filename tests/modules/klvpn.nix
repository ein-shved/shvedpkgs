{ testers }:
testers.runNixOSTest {
  name = "klvpn";
  nodes.machine = { config, lib, ... }: {
    user.name = "tester";
    services.klvpn.enable = true;
    assertions = [
      {
        assertion = lib.hasInfix ''subject.user == "tester"'' config.security.polkit.extraConfig;
        message = "The VPN's polkit declarations refer to the primary account";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("pcscd.socket")
    machine.succeed("command -v klvpn")
    machine.succeed("id -nG tester | tr ' ' '\\n' | grep -Fx pkcs11")
    for name in ["libeToken", "libeTokenLegacy", "rutoken"]:
        module = machine.succeed(f"cat /etc/pkcs11/modules/{name}.module").strip()
        assert module.startswith("module: ")
        machine.succeed(f"test -f {module.removeprefix('module: ')}")
  '';
}
