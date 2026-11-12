{
  extensions,
  lib,
  pkgs,
  pkgsUnstable,
  testers,
}:
let
  evaluate =
    codex: printing3d: extra:
    (lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      specialArgs = { inherit extensions lib pkgsUnstable; };
      modules = extensions.modules ++ [
        ../../../config/services/codex
        {
          system.stateVersion = "26.05";
          user.name = "designer";
          environment.printing3d.enable = printing3d;
          services.codex = {
            enable = codex;
            user = "designer";
            package = pkgs.codex;
          };
        }
        extra
      ];
    }).config;
  selected = evaluate true true { };
  absent = [
    (evaluate false false { })
    (evaluate true false { })
    (evaluate false true { })
  ];
  overridden = evaluate true true {
    services.codex.settings.mcp_servers.prusaslicer = {
      command = "/custom/slicer-mcp";
      env.SLICER_PATH = "/custom/prusa-slicer";
      enabled = false;
    };
  };
  hasMcp = cfg: lib.elem pkgs.mcp-3d-printer-server cfg.environment.systemPackages;
  client = pkgs.writeText "prusaslicer-mcp-client.py" (builtins.readFile ./client.py);
in
assert hasMcp selected;
assert
  selected.services.codex.settings.mcp_servers.prusaslicer.command
  == lib.getExe pkgs.mcp-3d-printer-server;
assert
  selected.services.codex.settings.mcp_servers.prusaslicer.env.SLICER_PATH
  == lib.getExe' pkgs.prusa-slicer "prusa-slicer";
assert lib.all (
  cfg: !(cfg.services.codex.settings.mcp_servers or { } ? prusaslicer) && !hasMcp cfg
) absent;
assert overridden.services.codex.settings.mcp_servers.prusaslicer.command == "/custom/slicer-mcp";
assert
  overridden.services.codex.settings.mcp_servers.prusaslicer.env.SLICER_PATH
  == "/custom/prusa-slicer";
assert !overridden.services.codex.settings.mcp_servers.prusaslicer.enabled;
testers.runNixOSTest {
  name = "prusaslicer-mcp";
  requiredFeatures.kvm = false;
  nodes.machine =
    { lib, ... }:
    {
      imports = [ ../../../config/services/codex ];
      user.name = "designer";
      home.enable = false;
      environment.printing3d.enable = true;
      services.codex = {
        enable = true;
        user = "designer";
        package = pkgs.codex;
      };
      services.gitwatch.modeling3d.enable = lib.mkForce false;
      environment.systemPackages = [ pkgs.python3 ];
      virtualisation.memorySize = 2048;
    };
  testScript = ''
    import json
    import shlex

    machine.start()
    machine.wait_for_unit("codex.service")
    machine.succeed("test ! -e /home/designer/.codex/config.toml")

    def user(command):
        return "runuser -u designer -- sh -c " + shlex.quote("cd /home/designer && " + command)

    with subtest("local slicing through shared Codex MCP configuration"):
        try:
            machine.succeed(user("env -u DISPLAY -u WAYLAND_DISPLAY -u API_KEY python ${client} > slice-result.json"))
        except Exception:
            print(machine.execute("cat /home/designer/mcp-server.log /home/designer/slice-result.json"))
            raise

    with subtest("user settings override shared registration"):
        machine.succeed(user("printf '[mcp_servers.prusaslicer]\\nenabled = false\\n' > .codex/config.toml"))
        connection = json.loads(machine.succeed(user("codex mcp get prusaslicer --json")))
        assert connection["enabled"] is False
        machine.succeed(user("test -w .codex/config.toml"))

    machine.copy_from_machine("/home/designer/mcp-server.log")
    machine.copy_from_machine("/home/designer/slice-result.json")
    machine.copy_from_machine("/home/designer/slice-result.gcode")
  '';
}
