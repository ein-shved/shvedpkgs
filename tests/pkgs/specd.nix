{
  gitMinimal,
  specd,
  testers,
}:

testers.runNixOSTest {
  name = "specd";

  nodes.machine =
    { ... }:
    {
      environment.systemPackages = [
        gitMinimal
        specd
      ];

      system.stateVersion = "26.05";
    };

  testScript = ''
    start_all()

    machine.succeed("specd --version | grep -Fx 0.2.0")
    machine.succeed("specd --help | grep -F 'cli  v0.2.0'")
    machine.succeed("specd --help | grep -F 'core v0.2.0'")
    machine.succeed("mkdir -p /tmp/specd-graph-test")
    machine.succeed("cd /tmp/specd-graph-test && git init")
    machine.succeed("cd /tmp/specd-graph-test && specd init --schema @specd/schema-std --workspace default --workspace-path specs/")
    machine.succeed("cd /tmp/specd-graph-test && specd graph index --format toon")
  '';
}
