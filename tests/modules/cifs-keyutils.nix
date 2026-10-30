{ testers }:
testers.runNixOSTest {
  name = "cifs-keyutils";
  nodes.machine = {
    services.cifsKeyutils.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("command -v cifs.upcall")
    machine.succeed("command -v keyctl")
    machine.succeed("grep -E '^create[[:space:]]+cifs[.]spnego[[:space:]]+.*cifs[.]upcall -t %k$' /etc/request-key.conf")
    machine.succeed("grep -E '^create[[:space:]]+dns_resolver[[:space:]]+.*cifs[.]upcall %k$' /etc/request-key.conf")
    machine.succeed("test /sbin/request-key -ef /run/current-system/sw/bin/request-key")
    # Exercise the kernel's request-key callout and the configured helper.
    machine.succeed("keyctl pipe $(keyctl request2 user debug:loop:runner project-runner @s) | grep -Fx project-runner")
  '';
}
