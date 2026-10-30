{ testers }:
testers.runNixOSTest {
  name = "home-manager";
  nodes.machine = { config, options, ... }: {
    user.name = "tester";
    home.enable = true;
    hm.home.file."runner-marker".text = "project-runner";
    assertions = [
      {
        assertion = config.hm.home.username == "tester"
          && config.hm.home.homeDirectory == "/home/tester"
          && config.hm.home.stateVersion == config.system.stateVersion
          && config.home-manager.useGlobalPkgs
          && options.hm.type.name == "deferredModule"
          && !(config.hm.home.activation ? preInstallPackages)
          && !(config.hm.home.activation ? mergeMzNssDb);
        message = "Primary HM projects the account and keeps optional activation steps disabled";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("getent passwd tester")
    machine.succeed("su - tester -c 'grep -Fx project-runner ~/runner-marker'")
  '';
}
