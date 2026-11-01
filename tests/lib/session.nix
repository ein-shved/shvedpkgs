{ writeShellScript }:
# Shared disposable user/session setup for the pass and keyring storage tests.
let
  # Commands invoked through su must use the logged-in user's existing bus.
  inSession = writeShellScript "in-credential-test-session" ''
    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus
    exec "$@"
  '';
in
{
  # Public fixture credentials belong only to the test VM, never the host user.
  node = {
    user = {
      name = "fixture";
      password = "fixture-login";
    };
    services.dbus.enable = true;
    system.stateVersion = "24.11";
  };
  # Python helpers included in each consuming NixOS VM test script.
  driverHelpers = ''
    import shlex

    def user(command):
        return "su - fixture -c " + shlex.quote("${inSession} " + command)

    def login():
        # Ordinary tty/PAM login creates the runtime directory and user manager;
        # it also exercises the provider's normal PAM unlock when configured.
        machine.wait_for_unit("getty@tty1.service")
        machine.wait_until_tty_matches("1", "login: ", timeout=60)
        machine.send_chars("fixture\n")
        machine.wait_until_tty_matches("1", "Password:", timeout=30)
        machine.send_chars("fixture-login\n")
        machine.wait_until_succeeds("systemctl is-active user@1000.service", timeout=60)
        machine.wait_for_unit("dbus.socket", user="fixture")
        machine.succeed("loginctl show-user fixture -p State --value | grep -x active")
  '';
}
