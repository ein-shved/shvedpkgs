{ testers }:
testers.runNixOSTest {
  name = "home-manager-refresh";
  nodes.machine = { config, ... }: {
    user.name = "tester";
    home.enable = true;
    home.refresh-profile.enable = true;
    nix.settings.experimental-features = [ "nix-command" ];
    assertions = [
      {
        assertion = config.hm.home.activation.preInstallPackages.before == [ "installPackages" ];
        message = "Profile initialization precedes Home Manager package installation";
      }
    ];
  };
  testScript = { nodes }: ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("test -f ${nodes.machine.hm.home.profileDirectory}/manifest.json")
    machine.succeed("systemctl restart home-manager-tester.service")
    machine.succeed("test -f ${nodes.machine.hm.home.profileDirectory}/manifest.json")
  '';
}
