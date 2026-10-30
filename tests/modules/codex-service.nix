{
  testers,
  pkgs,
  pkgsUnstable,
  lib,
}:
let
  python = pkgs.python3.withPackages (p: [ p.pexpect ]);
  client = pkgs.writeText "codex-client.py" ''
    import os
    import pexpect

    child = pexpect.spawn(
        "${lib.getExe pkgsUnstable.codex}",
        ["--remote", "unix://", "--no-alt-screen"],
        env=dict(os.environ, TERM="xterm-256color"),
        encoding="utf-8", timeout=60,
    )
    try:
        with open("/home/developer/client.log", "w") as log:
            child.logfile = log
            # Answer terminal position queries until authentication onboarding.
            while child.expect([r"\x1b\[6n", "Sign in with ChatGPT"]) == 0:
                child.send("\x1b[1;1R")
            child.sendcontrol("c")
    finally:
        child.close(force=True)
  '';
in
testers.runNixOSTest {
  name = "codex-service";
  requiredFeatures.kvm = false;
  nodes.machine = {
    imports = [ ../../config/services/codex ];
    hardware.isDevelopment = true;
    user = {
      name = "developer";
      password = "";
    };
    environment.systemPackages = [ python ];
  };
  testScript = ''
    import shlex

    machine.start()
    machine.wait_for_unit("codex.service")
    machine.succeed("systemctl is-enabled codex.service")
    machine.fail("loginctl list-sessions --no-legend | grep -w developer")

    def server_pid():
        unit = machine.get_unit_info("codex.service")
        assert unit["ActiveState"] == "active"
        assert unit["NRestarts"] == "0"
        assert machine.succeed("pgrep -u developer -f 'codex app-server' | wc -l").strip() == "1"
        return unit["MainPID"]

    with subtest("service starts in the user's environment before login"):
        unit = machine.get_unit_info("codex.service")
        assert unit["User"] == "developer"
        assert unit["WorkingDirectory"] == "/home/developer"
        assert unit["Restart"] == "on-failure"
        assert "--remote-control" in unit["ExecStart"]
        assert {"HOME=/home/developer", "CODEX_HOME=/home/developer/.codex"} <= set(shlex.split(unit["Environment"]))
        machine.wait_until_succeeds("test -S /home/developer/.codex/app-server-control/app-server-control.sock")
        machine.succeed("runuser -u developer -- touch /home/developer/.codex/writable")
        machine.succeed("test ! -e /home/developer/.codex/auth.json")
        pid = server_pid()
        assert machine.succeed(f"readlink /proc/{pid}/exe").strip() == "${lib.getExe pkgsUnstable.codex}"
        assert "Codex could not find bubblewrap on PATH" not in machine.succeed(
            "journalctl -u codex.service --no-pager"
        )

    with subtest("CLI attaches to the service and disconnects"):
        machine.succeed("runuser -u developer -- env HOME=/home/developer CODEX_HOME=/home/developer/.codex ${python}/bin/python ${client}", timeout=90)
        machine.sleep(15)
        assert server_pid() == pid

    with subtest("local login and logout preserve the service"):
        machine.send_key("alt-f2")
        machine.wait_for_unit("getty@tty2.service")
        machine.wait_until_tty_matches("2", "login: ")
        machine.send_chars("developer\n")
        machine.wait_until_succeeds("pgrep -u developer bash")
        sessions = machine.succeed("loginctl show-user developer -p Sessions --value").split()
        assert any(
            machine.succeed(f"loginctl show-session {shlex.quote(session)} -p Service --value").strip() == "login"
            for session in sessions
        )
        machine.send_chars("codex --version > ~/codex-version\n")
        machine.wait_for_file("/home/developer/codex-version")
        assert machine.succeed("cat /home/developer/codex-version").strip() == "codex-cli ${pkgsUnstable.codex.version}"
        machine.send_chars("exit\n")
        machine.wait_until_fails("loginctl list-sessions --no-legend | grep -w developer")
        machine.sleep(15)
        assert server_pid() == pid
        machine.succeed("test ! -e /home/developer/.codex/auth.json")

    machine.copy_from_vm("/home/developer/client.log")
  '';
}
