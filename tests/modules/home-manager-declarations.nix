{ testers }:
testers.runNixOSTest {
  name = "home-manager-declarations";
  nodes.machine = { config, lib, ... }: {
    user.name = "tester";
    home.enable = true;
    hm = {
      imports = [
        ({ config, pkgs, ... }: {
          home.file.from-module.text = "${config.home.username}:${pkgs.stdenv.hostPlatform.system}";
        })
      ];
      home.file = {
        from-login.text = config.user.name;
        from-alias.text = config.hm.home.username;
        selected = lib.mkIf true { text = "selected"; };
        unused = lib.mkIf false { text = throw "inactive home branch was evaluated"; };
      };
    };
    home-manager.users.tester.home.file.direct.text = "direct";
    assertions = [
      {
        assertion = config.hm.home.file.direct.text == "direct";
        message = "Direct HM declarations are visible through the primary alias";
      }
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("grep -Fx tester /home/tester/from-login")
    machine.succeed("grep -Fx tester /home/tester/from-alias")
    machine.succeed("grep -Fx tester:x86_64-linux /home/tester/from-module")
    machine.succeed("grep -Fx direct /home/tester/direct")
    machine.succeed("grep -Fx selected /home/tester/selected && test ! -e /home/tester/unused")
  '';
}
