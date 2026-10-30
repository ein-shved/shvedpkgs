{ pkgsOrigin, lib, extensions }:
pkgsOrigin.testers // {
  runNixOSTest = testModule: pkgsOrigin.testers.runNixOSTest {
    imports = [
      testModule
      (import ./project-test-support.nix { inherit lib extensions; })
    ];
  };
}
