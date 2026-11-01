{
  testers,
  callPackage,
}:
let
  session = callPackage ../lib/session.nix { };
  pinentry = callPackage ./stubs/credential-storage/pinentry.nix { };
  fixture = callPackage ./stubs/credential-storage/pass-fixture.nix { };
in
testers.runNixOSTest {
  name = "pass";
  nodes.machine = { config, ... }: {
    imports = [
      session.node
      fixture.node
    ];
    home.enable = true;
    # Keep VM profile builds separate from the primary user's default groups.
    nix.settings.build-users-group = "pass-test-builders";
    users.groups.pass-test-builders = { };
    users.users.nixbld1.extraGroups = [ "pass-test-builders" ];
    # HM builds its profile in the guest; keep that store across cold boots.
    virtualisation.writableStoreUseTmpfs = false;
    programs.pass = {
      enable = true;
      gpgid = fixture.key;
      giturl = fixture.repository;
    };
    programs.gnupg.agent.pinentryPackage = pinentry;
    assertions = [
      {
        assertion = config.programs.gnupg.agent.enable && config.home.enable;
        message = "The pass regression exercises the primary HM activation";
      }
    ];
  };
  testScript = ''
    ${session.driverHelpers}

    def read_password():
        assert machine.succeed(user("pass show fixture")).strip() == "fixture-secret"
        assert len(machine.succeed("pgrep -u fixture -x keyboxd").splitlines()) == 1
        machine.succeed("test -S /run/user/1000/gnupg/S.keyboxd")
        machine.succeed("test ! -S /home/fixture/.gnupg/S.keyboxd")

    def check_setup():
        # Inspect persistent outputs without invoking GPG to prepare the user.
        machine.succeed("test -s /var/lib/pass-fixture/keygrips")
        machine.succeed("while read -r grip; do test -s /home/fixture/.gnupg/private-keys-v1.d/$grip.key; done < /var/lib/pass-fixture/keygrips")
        for name in [".gpg-id", "fixture.gpg"]:
            machine.succeed(f"cmp /var/lib/pass-fixture/password-store/{name} /home/fixture/.password-store/{name}")
        assert machine.succeed(user("pass git branch --show-current")).strip() == "main"

    start_all()
    try:
        machine.wait_for_unit("home-manager-fixture.service")
        # HM installs the user service without starting GPG before login.
        machine.succeed("test ! -d /home/fixture/.gnupg/private-keys-v1.d")
        machine.succeed("test ! -e /home/fixture/.password-store")
        machine.fail("pgrep -u fixture -x keyboxd")
        machine.succeed("su - fixture -c 'pass otp --help' | grep -F 'pass otp'")
        login()
        machine.wait_for_unit("pass-setup.service", user="fixture")
        check_setup()
        read_password()
        # Repeat activation and setup without replacing the existing store.
        machine.succeed("systemctl restart home-manager-fixture.service")
        machine.succeed(user("systemctl --user restart pass-setup.service"))
        check_setup()
        read_password()
        machine.shutdown()
        machine.start()
        machine.wait_for_unit("home-manager-fixture.service")
        login()
        machine.wait_for_unit("pass-setup.service", user="fixture")
        check_setup()
        read_password()
    except Exception:
        for command in [
            "journalctl -b -u pass-fixture -u home-manager-fixture --no-pager",
            user("journalctl --user -b -u pass-setup --no-pager"),
            "ps -C gpg-agent,keyboxd -o pid,ppid,euid,args",
            user("gpgconf --list-dirs"),
            "ss -xlpn | grep -E 'gnupg|keyboxd|gpg-agent'",
            "cat /home/fixture/.gnupg/public-keys.d/pubring.db.lock",
        ]:
            machine.log(machine.execute(command)[1])
        raise
  '';
}
