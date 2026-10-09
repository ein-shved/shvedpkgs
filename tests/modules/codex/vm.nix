{
  testers,
  codex,
  python3,
  writeText,
  ...
}:
let
  python = python3.withPackages (p: [ p.pexpect ]);
  clientProbe = writeText "codex-client-probe.py" ''
    import os
    import re
    import pexpect

    child = pexpect.spawn(
        "${codex}/bin/codex",
        ["--remote", "unix://", "--no-alt-screen"],
        env=dict(os.environ, TERM="xterm-256color"),
        encoding="utf-8", timeout=45, dimensions=(40, 120),
    )
    with open("/home/developer/client.log", "w") as log:
        child.logfile = log
        # Terminal capability queries may precede the onboarding screen.
        while True:
            result = child.expect([
                r"\x1b\[6n",
                re.compile(r"Sign in|Log in|ChatGPT|API key", re.IGNORECASE),
                pexpect.EOF,
            ])
            if result == 0:
                child.send("\x1b[1;1R")
            elif result == 1:
                print("Connected CLI reached authentication onboarding")
                break
            else:
                raise RuntimeError("CLI exited before connected onboarding: " + child.before)
        child.sendcontrol("c")
        child.close(force=True)
  '';
in
testers.runNixOSTest {
  name = "codex-service";
  requiredFeatures.kvm = false;
  nodes.machine = { lib, ... }: {
    imports = [ ../../../modules/services/codex ];
    system.stateVersion = "26.05";
    users.users.developer = {
      isNormalUser = true;
      home = "/home/developer";
      createHome = true;
    };
    services.codex = {
      enable = true;
      user = "developer";
      remoteControl.enable = true;
      package = codex;
    };
    # Test-driver commands use the serial console; the guest needs no NIC.
    virtualisation.vlans = [ ];
    virtualisation.qemu.networkingOptions = lib.mkForce [ ];
    virtualisation.qemu.options = [ "-nic none" ];
    virtualisation.memorySize = 2048;
    environment.systemPackages = [ python ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("systemctl cat codex.service")
    machine.succeed("systemctl is-enabled codex.service")
    machine.wait_for_unit("codex.service")
    machine.succeed("test -z \"$(ip route show default)\"")
    machine.succeed("test -z \"$(ip -6 route show default)\"")
    machine.succeed("test \"$(ls /sys/class/net)\" = lo")
    machine.succeed("test ! -e /home/developer/.codex/auth.json")
    machine.wait_until_succeeds("test -S /home/developer/.codex/app-server-control/app-server-control.sock")
    before = machine.succeed("systemctl show codex.service -p MainPID --value").strip()
    machine.succeed("runuser -u developer -- env HOME=/home/developer CODEX_HOME=/home/developer/.codex ${python}/bin/python ${clientProbe}", timeout=60)
    machine.succeed("test \"$(pgrep -u developer -f 'codex app-server' | wc -l)\" -eq 1")
    # Observe stability after the CLI disconnects, including at least one retry interval.
    machine.sleep(15)
    machine.succeed("systemctl is-active codex.service")
    machine.succeed("test \"$(ls /sys/class/net)\" = lo")
    assert machine.succeed("systemctl show codex.service -p MainPID --value").strip() == before
    machine.succeed("test \"$(systemctl show codex.service -p NRestarts --value)\" -eq 0")
    machine.succeed("journalctl -u codex.service -b --no-pager")
    machine.copy_from_vm("/home/developer/client.log")
  '';
}
