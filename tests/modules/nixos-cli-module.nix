{
  lib,
  extensions,
  pkgs,
  testers,
}:
let
  recorder = pkgs.writeScriptBin "nixos-rebuild" ''
    #!${pkgs.python3}/bin/python3
    import json
    import os
    import sys
    print(json.dumps({"argv": sys.argv[1:], "catalog": os.environ["NIXOS_CLI_CONFIG"]}))
  '';
  common = {
    inherit (extensions.flake-inputs.self) mkSystem;
    inherit (extensions) modules;
    defaultSystem = pkgs.stdenv.hostPlatform.system;
    defaultHost = "controller";
    specialArgs.extensions = {
      marker = "shared";
      nixosConfigurations = throw "inherited configurations were not refreshed";
    };
    configs = [
      ({ lib, extensions, ... }: {
        options.test.visibleHosts = lib.mkOption { type = lib.types.listOf lib.types.str; };
        options.test.extensionMarker = lib.mkOption { type = lib.types.str; };
        config = {
          test.visibleHosts = builtins.attrNames extensions.nixosConfigurations;
          test.extensionMarker = extensions.marker;
          system.stateVersion = "26.05";
          nixpkgs.overlays = [
            (_: prev: { nixos-cli = prev.nixos-cli.override { nixos-rebuild = recorder; }; })
          ];
        };
      })
    ];
    validationModules = [ { programs.nixos-cli.remoteAddress = lib.mkForce "validation-only"; } ];
  };
  host = hostname: address: extra: {
    configs = [
      {
        networking.hostName = hostname;
        programs.nixos-cli.remoteAddress = address;
      }
      extra
    ];
  };
  base = lib.mkExtendableSystems (
    common
    // {
      hosts = {
        controller = host "controller-static" null {
          programs.nixos-cli.enable = true;
          security.sudo.wheelNeedsPassword = false;
          user.name = "launcher";
        };
        alpha = host "keyTarget" "old.example" { user.name = "old"; };
        keyTarget = host "key-host" "key.example" {
          user.name = "key-user";
          programs.nixos-cli.useSudo = false;
        };
        duplicateA = host "shared-host" "a.example" { user.name = "alice"; };
        duplicateB = host "shared-host" "b.example" { user.name = "bob"; };
        noUser = host "bare-host" "bare.example" {
          security.sudo.wheelNeedsPassword = false;
        };
        forceAsk = host "ask-host" "ask.example" {
          user.name = "ask-user";
          security.sudo.wheelNeedsPassword = false;
          programs.nixos-cli.askSudoPassword = true;
        };
        forceSilent = host "silent-host" "silent.example" {
          user.name = "silent-user";
          security.sudo.wheelNeedsPassword = true;
          programs.nixos-cli.askSudoPassword = false;
        };
      };
    }
  ) { };
  final = base.extend {
    hosts = {
      alpha = host "keyTarget" "new.example" { user.name = "new-user"; };
      added = host "added-host" "added.example" {
        user.name = "added-user";
        security.sudo.wheelNeedsPassword = false;
      };
    };
  };
  collision = final.extend {
    hosts.runtime = host "module-runtime" "runtime.example" {
      user.name = "remote-user";
      programs.nixos-cli.useSudo = false;
    };
  };
  empty = lib.mkExtendableSystems (
    common
    // {
      hosts.controller = host "empty-static" null { programs.nixos-cli.enable = true; };
    }
  ) { };
  command =
    assembly:
    lib.findFirst (p: (p.pname or "") == "nixos-cli") (throw "enabled module did not install nixos-cli")
      assembly.nixosConfigurations.controller.config.environment.systemPackages;
  hasCommand =
    host: lib.any (p: (p.pname or "") == "nixos-cli") host.config.environment.systemPackages;
  finalHosts = final.nixosConfigurations;
  invalid = base.extend { hosts.bad = host "bad" "" { }; };
  deselected = final.extend {
    hosts.controller = host "controller-static" null { programs.nixos-cli.enable = false; };
  };
  disabled = extensions.flake-inputs.nixpkgs.lib.nixosSystem {
    system = pkgs.stdenv.hostPlatform.system;
    specialArgs.extensions = throw "disabled module forced the configuration set";
    modules = [
      ../../modules/tools/nixos-cli
      {
        system.stateVersion = "26.05";
        nixpkgs.overlays = [ (_: _: { nixos-cli = throw "disabled module forced its package"; }) ];
      }
    ];
  };
in
assert !hasCommand finalHosts.alpha;
assert !hasCommand deselected.nixosConfigurations.controller;
assert !hasCommand disabled;
assert !disabled.config.programs.nixos-cli.enable;
assert disabled.config.programs.nixos-cli.remoteAddress == null;
assert finalHosts.controller.config.test.extensionMarker == "shared";
assert finalHosts.alpha.config.programs.nixos-cli.remoteAddress == "new.example";
assert finalHosts.controller.config.programs.nixos-cli.remoteAddress == null;
assert finalHosts.controller.config.test.visibleHosts == builtins.attrNames finalHosts;
assert
  base.nixosConfigurations.controller.config.test.visibleHosts
  == builtins.attrNames base.nixosConfigurations;
assert !(builtins.elem "added" base.nixosConfigurations.controller.config.test.visibleHosts);
assert
  final.nixosValidationConfigurations.alpha.config.programs.nixos-cli.remoteAddress
  == "validation-only";
assert
  !(builtins.tryEval invalid.nixosConfigurations.bad.config.programs.nixos-cli.remoteAddress).success;
testers.runNixOSTest {
  name = "nixos-cli-module";
  nodes.machine = {
    networking.hostName = "module-runtime";
    environment.systemPackages = [ (command final) ];
  };
  testScript = ''
    import json
    import shlex

    start_all()
    machine.wait_for_unit("multi-user.target")

    def invoke(args, binary="nixos"):
        # The package wrapper must replace this invalid caller-supplied path.
        result = machine.succeed("NIXOS_CLI_CONFIG=/missing-caller-catalog " + shlex.quote(binary) + " " + shlex.join(args))
        return json.loads(result)

    def read_catalog(result):
        path = result["catalog"]
        assert path.startswith("/nix/store/") and path.endswith("nixos-cli-catalog.json"), path
        return json.loads(machine.succeed("cat " + shlex.quote(path)))

    local = invoke(["switch"])
    assert local["argv"] == ["switch"], local
    catalog = read_catalog(local)
    expected = {
        "alpha": {"target_host": "new.example", "user": "new-user", "use_sudo": True, "ask_sudo_password": True},
        "keyTarget": {"target_host": "key.example", "user": "key-user", "use_sudo": False, "ask_sudo_password": True},
        "duplicateA": {"target_host": "a.example", "user": "alice", "use_sudo": True, "ask_sudo_password": True},
        "duplicateB": {"target_host": "b.example", "user": "bob", "use_sudo": True, "ask_sudo_password": True},
        "noUser": {"target_host": "bare.example", "use_sudo": True, "ask_sudo_password": False},
        "forceAsk": {"target_host": "ask.example", "user": "ask-user", "use_sudo": True, "ask_sudo_password": True},
        "forceSilent": {"target_host": "silent.example", "user": "silent-user", "use_sudo": True, "ask_sudo_password": False},
        "added": {"target_host": "added.example", "user": "added-user", "use_sudo": True, "ask_sudo_password": False},
    }
    for name, settings in expected.items():
        assert catalog[name] == settings, (name, catalog[name])
    for alias, canonical in {
        "key-host": "keyTarget", "bare-host": "noUser", "ask-host": "forceAsk",
        "silent-host": "forceSilent", "added-host": "added",
    }.items():
        assert catalog[alias] == catalog[canonical], alias
    assert catalog["shared-host"] in [catalog["duplicateA"], catalog["duplicateB"]]
    assert set(catalog) == set(expected) | {"key-host", "shared-host", "bare-host", "ask-host", "silent-host", "added-host"}, catalog

    for name, settings in catalog.items():
        address = settings["target_host"]
        if "user" in settings:
            address = settings["user"] + "@" + address
        argv = ["--target-host", address]
        if settings["use_sudo"]:
            argv += ["--ask-sudo-password" if settings["ask_sudo_password"] else "--sudo"]
        argv += ["switch"]
        result = invoke([name, "switch"])
        assert result["argv"] == argv, (name, result)
        assert result["catalog"] == local["catalog"]

    assert invoke(["module-runtime", "switch"])["argv"] == ["switch"]
    help_text = machine.succeed("nixos --help")
    assert "module-runtime" in help_text and "added-host" in help_text
    assert read_catalog(local) == catalog and "module-runtime" not in catalog

    empty_binary = "${command empty}/bin/nixos"
    empty_result = invoke(["switch"], empty_binary)
    assert read_catalog(empty_result) == {}
    assert invoke(["module-runtime", "switch"], empty_binary)["argv"] == ["switch"]
    assert "module-runtime" in machine.succeed(empty_binary + " --help")
    assert read_catalog(empty_result) == {}

    collision_binary = "${command collision}/bin/nixos"
    collision_result = invoke(["module-runtime", "switch"], collision_binary)
    assert collision_result["argv"] == ["--target-host", "remote-user@runtime.example", "switch"]
    assert read_catalog(collision_result)["module-runtime"] == {
        "target_host": "runtime.example", "user": "remote-user", "use_sudo": False, "ask_sudo_password": True,
    }
    assert invoke(["switch"], collision_binary)["argv"] == ["switch"]
  '';
}
