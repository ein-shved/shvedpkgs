{
  testers,
  pkgs,
  lib,
}:
let
  configClient =
    pkgs.writers.writePython3 "codex-config-client"
      {
        libraries = [ pkgs.python3Packages.websockets ];
      }
      ''
        import json
        import os
        import selectors
        import subprocess
        import sys
        import time
        from websockets.sync.client import unix_connect

        CODEX = "${lib.getExe pkgs.codex}"

        child = None
        remote = None
        try:
            if sys.argv[1] == "local":
                child = subprocess.Popen(
                    [CODEX, "app-server", "--stdio", "--strict-config"],
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL,
                )
                selector = selectors.DefaultSelector()
                selector.register(child.stdout, selectors.EVENT_READ)
                buffered = bytearray()
            else:
                remote = unix_connect(
                    os.path.join(
                        os.environ["CODEX_HOME"],
                        "app-server-control/app-server-control.sock",
                    ),
                    uri="ws://localhost/rpc", open_timeout=30, close_timeout=5,
                )

            def request(identifier, method, params):
                payload = json.dumps(
                    {"id": identifier, "method": method, "params": params}
                )
                if remote is not None:
                    remote.send(payload)
                else:
                    child.stdin.write((payload + "\n").encode())
                    child.stdin.flush()
                deadline = time.monotonic() + 30
                while True:
                    assert (
                        time.monotonic() < deadline
                    ), "app-server response timed out"
                    if remote is not None:
                        line = remote.recv(timeout=deadline - time.monotonic())
                    else:
                        while b"\n" not in buffered:
                            remaining = deadline - time.monotonic()
                            assert (
                                remaining > 0 and selector.select(remaining)
                            ), "app-server response timed out"
                            chunk = os.read(child.stdout.fileno(), 65536)
                            assert chunk, "app-server closed output"
                            buffered.extend(chunk)
                        line, _, rest = buffered.partition(b"\n")
                        buffered[:] = rest
                    reply = json.loads(line)
                    if reply.get("id") == identifier:
                        assert "error" not in reply, reply
                        return reply["result"]

            request(
                1, "initialize",
                {"clientInfo": {"name": "codex-config-test", "version": "1"}},
            )
            result = request(2, "config/read", {"includeLayers": True})
            config = result["config"]
            system = next(
                (
                    layer["config"] for layer in result["layers"]
                    if layer["name"]["type"] == "system"
                ),
                None,
            )
            print(json.dumps({
                "effort": config["model_reasoning_effort"],
                "verbosity": config.get("model_verbosity"),
                "status_line": config["tui"]["status_line"],
                "vim": config["tui"]["vim_mode_default"],
                "animations": config["tui"].get("animations"),
                "system_keys": sorted(system) if system is not None else None,
            }))
        finally:
            if remote is not None:
                remote.close()
            if child is not None:
                child.terminate()
                try:
                    child.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait()
      '';
  userConfig = pkgs.writeText "codex-user-config.toml" ''
    # Local preferences stay writable and survive system updates.
    model_verbosity = "low"
    [tui]
    vim_mode_default = false
    status_line = ["git-branch", "project-name"]
  '';
in
testers.runNixOSTest {
  name = "codex-config";
  requiredFeatures.kvm = false;
  nodes.machine = {
    imports = [ ../../config/services/codex ];
    hardware.isDevelopment = false;
    user = {
      name = "developer";
      password = "";
    };
    services.codex = {
      enable = true;
      user = "developer";
      package = pkgs.codex;
    };
    specialisation.updated.configuration.services.codex.settings = {
      model_reasoning_effort = lib.mkForce "high";
      tui.status_line = lib.mkForce [ "project-name" ];
      tui.animations = false;
    };
  };
  testScript =
    { nodes, ... }:
    ''
      import json
      import shlex

      machine.start()
      machine.wait_for_unit("codex.service")
      machine.wait_until_succeeds("test -S /home/developer/.codex/app-server-control/app-server-control.sock")

      def read_config(mode="remote", codex_home="/home/developer/.codex"):
          command = (
              "runuser -u developer -- env HOME=/home/developer CODEX_HOME=" + shlex.quote(codex_home)
              + " ${configClient} " + mode
          )
          return json.loads(machine.succeed(command))

      with subtest("fresh local and remote clients load shared configuration"):
          machine.succeed("runuser -u developer -- mkdir /home/developer/fresh-codex")
          machine.succeed("test ! -e /home/developer/.codex/config.toml")
          for config in [read_config(), read_config("local", "/home/developer/fresh-codex")]:
              assert config["system_keys"] == ["model_reasoning_effort", "tui"]
              assert config["effort"] == "xhigh"
              assert config["vim"] is True
              assert config["status_line"] == [
                  "thread-name", "project-name", "git-branch", "five-hour-limit",
                  "weekly-limit", "used-tokens", "model-with-reasoning",
              ]
          machine.succeed("test ! -e /home/developer/fresh-codex/config.toml")

      with subtest("local additions and overrides take precedence"):
          machine.succeed("runuser -u developer -- install -m600 ${userConfig} /home/developer/.codex/config.toml")
          machine.succeed("runuser -u developer -- touch /home/developer/.codex/local-note")
          config = read_config()
          assert config["verbosity"] == "low"
          assert config["vim"] is False
          assert config["status_line"] == ["git-branch", "project-name"]
          assert config["effort"] == "xhigh"

      with subtest("NixOS updates preserve local configuration and update defaults"):
          machine.succeed("${nodes.machine.system.build.toplevel}/specialisation/updated/bin/switch-to-configuration test")
          machine.wait_for_unit("codex.service")
          config = read_config()
          assert config["verbosity"] == "low"
          assert config["vim"] is False
          assert config["status_line"] == ["git-branch", "project-name"]
          assert config["effort"] == "high"
          assert config["animations"] is False
          machine.succeed("cmp ${userConfig} /home/developer/.codex/config.toml")
          machine.succeed("runuser -u developer -- test -w /home/developer/.codex/config.toml")
          machine.succeed("test -e /home/developer/.codex/local-note")

          fresh = read_config("local", "/home/developer/fresh-codex")
          assert fresh["effort"] == "high"
          assert fresh["vim"] is True
          assert fresh["status_line"] == ["project-name"]
          assert fresh["animations"] is False
    '';
}
