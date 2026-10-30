{ testers }:
testers.runNixOSTest {
  name = "home-manager-independent";
  nodes.machine = { config, options, ... }: {
    users.users.secondary = {
      isNormalUser = true;
      home = "/srv/secondary";
    };
    home-manager.users.secondary.home = {
      stateVersion = config.system.stateVersion;
      file.independent.text = "secondary";
    };
    home.refresh-profile.enable = true;
    hm.home.file.primary.text = throw "primary declarations leaked into the secondary home";
    assertions = [
      {
        assertion = !options.user.name.isDefined
          && !config.home.enable
          && !config.home-manager.useGlobalPkgs
          && !(config.users.users ? "");
        message = "Independent HM does not select a primary account or consume its declarations";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-secondary.service")
    machine.fail("getent passwd tester")
    machine.succeed("su - secondary -c 'grep -Fx secondary ~/independent && test ! -e ~/primary'")
  '';
}
