{ testers }:
testers.runNixOSTest {
  name = "project-arguments";
  nodes.machine = { lib, flake-inputs, pkgsUnstable, pkgs, ... }: {
    environment.systemPackages = [
      (
        assert lib.getSurname "Test Runner" == "Runner";
        assert flake-inputs.home-manager ? outPath;
        assert pkgsUnstable.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system;
        pkgs.hello
      )
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed("hello | grep -Fx 'Hello, world!'")
  '';
}
