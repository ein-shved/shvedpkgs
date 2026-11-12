{
  extensions,
  lib,
  pkgs,
  pkgsUnstable,
  testers,
}:
let
  evaluate =
    codex: freecad: extra:
    (lib.nixosSystem {
      system = pkgs.stdenv.hostPlatform.system;
      specialArgs = { inherit extensions lib pkgsUnstable; };
      modules = extensions.modules ++ [
        ../../../config/services/codex
        {
          system.stateVersion = "26.05";
          user.name = "designer";
          environment.printing3d.enable = freecad;
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
    services.codex.settings.mcp_servers.freecad = {
      command = "/custom/freecad-mcp";
      args = [ "--custom" ];
      enabled = false;
    };
  };
  hasMcp = cfg: lib.any (p: (p.pname or "") == "freecad-mcp") cfg.environment.systemPackages;
  client = pkgs.writeText "freecad-mcp-client.py" (builtins.readFile ./client.py);
  prepare = pkgs.writeText "freecad-mcp-prepare.py" ''
    import sys
    from pathlib import Path
    import FreeCAD as App

    App.ParamGet("User parameter:BaseApp/Preferences/McpTest").SetString("Sentinel", "keep-user-preference")
    App.ParamGet("User parameter:BaseApp/Preferences/General").SetString("AutoloadModule", "PartDesignWorkbench")
    App.saveParameter()
    (Path.home() / "data-dir").write_text(App.getUserAppDataDir())
    (Path.home() / "user-config-path").write_text(App.ConfigGet("UserParameter"))
    sys.exit(0)
  '';
in
assert hasMcp selected;
assert selected.services.codex.settings.mcp_servers.freecad.command == lib.getExe pkgs.freecad-mcp;
assert lib.all (
  cfg: !(cfg.services.codex.settings.mcp_servers or { } ? freecad) && !hasMcp cfg
) absent;
assert
  overridden.services.codex.settings.mcp_servers.freecad == {
    command = "/custom/freecad-mcp";
    args = [ "--custom" ];
    enabled = false;
  };
testers.runNixOSTest {
  name = "freecad-mcp";
  requiredFeatures.kvm = false;
  nodes.machine =
    { lib, ... }:
    {
      imports = [ ../../../config/services/codex ];
      user = {
        name = "designer";
        password = "";
      };
      home.enable = false;
      environment.printing3d.enable = true;
      hardware.graphics.enable = true;
      services.codex = {
        enable = true;
        user = "designer";
        package = pkgs.codex;
      };
      services.gitwatch.modeling3d.enable = lib.mkForce false;
      environment.systemPackages = [
        pkgs.python3
        pkgs.xvfb-run
      ];
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

    connection = json.loads(machine.succeed(user("codex mcp get freecad --json")))
    assert connection["enabled"] is True
    assert connection["transport"]["command"] == "${lib.getExe pkgs.freecad-mcp}"
    assert connection["transport"]["args"] == ["--host", "127.0.0.1"]

    machine.succeed("systemd-run --unit=mcp-lifecycle --collect --uid=designer --working-directory=/home/designer --setenv=HOME=/home/designer -p StandardOutput=append:/home/designer/lifecycle.log -p StandardError=inherit /run/current-system/sw/bin/python ${client} lifecycle ${lib.getExe pkgs.freecad-mcp} --host 127.0.0.1")
    machine.wait_for_file("/home/designer/closed-ready")

    machine.succeed(user("FreeCADCmd ${prepare} < /dev/null > prepare.log 2>&1"))
    try:
        data_dir = machine.succeed("cat /home/designer/data-dir").strip()
        assert data_dir.startswith("/home/designer/") and data_dir.endswith("/"), data_dir
    except Exception:
        print(machine.succeed("cat /home/designer/prepare.log"))
        raise
    settings_path = data_dir + "freecad_mcp_settings.json"
    user_cfg = machine.succeed("cat /home/designer/user-config-path").strip()
    assert user_cfg.startswith("/home/designer/"), user_cfg
    machine.succeed("test ! -e " + shlex.quote(settings_path))
    initial = "import json; p=" + repr(settings_path) + "; json.dump({'auto_start_rpc':False, 'custom_field':{'keep':[1,2,3]}},open(p,'w'))"
    machine.succeed(user("python -c " + shlex.quote(initial)))

    def check_settings():
        check = "import json, os, xml.etree.ElementTree as ET; p=" + repr(settings_path) + "; d=json.load(open(p)); assert d['auto_start_rpc'] is True; assert os.access(p, os.W_OK); assert d['custom_field'] == {'keep':[1,2,3]}"
        check += "; p=" + repr(user_cfg) + "; assert os.access(p, os.W_OK); root=ET.parse(p); assert root.find(\".//FCParamGroup[@Name='McpTest']/FCText[@Name='Sentinel']\").text == 'keep-user-preference'"
        machine.succeed(user("python -c " + shlex.quote(check)))

    def open_gui():
        machine.succeed("systemd-run --unit=freecad-test --collect --uid=designer --working-directory=/home/designer --setenv=HOME=/home/designer --setenv=LIBGL_ALWAYS_SOFTWARE=1 -p StandardOutput=append:/home/designer/freecad.log -p StandardError=inherit /run/current-system/sw/bin/xvfb-run -a /run/current-system/sw/bin/FreeCAD")
        try:
            machine.wait_until_succeeds("python -c \"import xmlrpc.client; assert xmlrpc.client.ServerProxy('http://127.0.0.1:9875').ping()\"", timeout=180)
        except Exception:
            print(machine.succeed("cat /home/designer/freecad.log"))
            raise
        listener = machine.succeed("ss -ltn '( sport = :9875 )'")
        assert "127.0.0.1:9875" in listener and "0.0.0.0:9875" not in listener, listener

    with subtest("normal GUI launch starts the bridge and a waiting MCP process finds FreeCAD"):
        open_gui()
        machine.succeed("touch /home/designer/gui-ready")
        try:
            machine.wait_until_succeeds("test -e /home/designer/connected-ready || ! systemctl is-active --quiet mcp-lifecycle.service", timeout=120)
            machine.succeed("test -e /home/designer/connected-ready")
        except Exception:
            print(machine.succeed("cat /home/designer/lifecycle.log /home/designer/mcp-server.log /home/designer/freecad.log"))
            raise
        check_settings()
        machine.succeed("systemctl stop freecad-test.service")
        machine.wait_until_fails("ss -ltn '( sport = :9875 )' | grep 127.0.0.1")

    with subtest("native user Codex settings override shared registration"):
        machine.succeed(user("printf '[mcp_servers.freecad]\\nenabled = false\\n' > .codex/config.toml"))
        connection = json.loads(machine.succeed(user("codex mcp get freecad --json")))
        assert connection["enabled"] is False
        machine.succeed(user("test -w .codex/config.toml"))

    machine.copy_from_vm("/home/designer/freecad.log")
    machine.copy_from_vm("/home/designer/prepare.log")
    machine.copy_from_vm("/home/designer/lifecycle.log")
    machine.copy_from_vm("/home/designer/mcp-server.log")
  '';
}
