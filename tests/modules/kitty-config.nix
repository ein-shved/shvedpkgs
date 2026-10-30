{ testers }:
testers.runNixOSTest {
  name = "kitty-config";
  nodes.machine = {
    imports = [ ../../config/desktop/kitty ];
    user.name = "tester";
    home.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("su - tester -c 'command -v kitty'")
    machine.succeed("grep -Fx 'background_opacity 0.7' /home/tester/.config/kitty/kitty.conf")
    machine.succeed("grep -Fx 'allow_remote_control yes' /home/tester/.config/kitty/kitty.conf")
    machine.succeed("grep -F KITTY_INSTALLATION_DIR /home/tester/.bashrc")
  '';
}
