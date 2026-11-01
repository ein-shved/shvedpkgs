{
  testers,
  callPackage,
  libsecret,
  writeShellScript,
}:
let
  session = callPackage ../lib/session.nix { };
  store = writeShellScript "store-keyring-password" ''
    set -eu
    printf '%s\n' fixture-app-password |
      ${libsecret}/bin/secret-tool store --label=fixture application credential-test
  '';
in
testers.runNixOSTest {
  name = "keyring-storage";
  nodes.machine = {
    imports = [
      session.node
      ../../config/desktop/default.nix
      ../../config/services/networking/ssh.nix
    ];
    hardware.isGraphic = true;
  };
  testScript = ''
    ${session.driverHelpers}

    def read_password():
        password = machine.succeed(user("${libsecret}/bin/secret-tool lookup application credential-test"))
        assert password.strip() == "fixture-app-password"

    start_all()
    login()
    # Use the real project provider policy and PAM login, without starting or
    # unlocking a replacement daemon. Missing Secret Service must fail here.
    machine.succeed(user("${store}"), timeout=30)
    read_password()
    machine.shutdown()
    machine.start()
    login()
    read_password()
  '';
}
