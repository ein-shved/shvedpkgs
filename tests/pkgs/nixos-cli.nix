{
  lib,
  path,
  testers,
  nixos-cli,
  python3,
  writeText,
}:
let
  keys = import (path + "/nixos/tests/ssh-keys.nix") { inherit writeText lib; };
  catalog = writeText "nixos-cli-test-catalog.json" (
    builtins.toJSON {
      deployer = {
        target_host = "deployer";
        user = "root";
        use_sudo = false;
        ask_sudo_password = false;
      };
      rootTarget = {
        target_host = "rootTarget";
        user = "root";
        use_sudo = false;
        ask_sudo_password = false;
      };
      sudoTarget = {
        target_host = "sudoTarget";
        user = "operator";
        use_sudo = true;
        ask_sudo_password = false;
      };
      passwordTarget = {
        target_host = "passwordTarget";
        user = "operator";
        use_sudo = true;
        ask_sudo_password = true;
      };
    }
  );
  command = nixos-cli.override { inherit catalog; };
  python = python3.withPackages (p: [ p.pexpect ]);
  passwordDriver = writeText "nixos-cli-password.py" ''
    import pexpect
    import sys

    password, expected, *argv = sys.argv[1:]
    child = pexpect.spawn(argv[0], argv[1:], encoding="utf-8", timeout=180)
    child.logfile_read = sys.stdout
    child.expect(r"\[sudo\] password for operator@passwordTarget:")
    child.sendline(password)
    child.expect(pexpect.EOF)
    child.close()
    if expected == "success":
        assert child.exitstatus == 0, (child.exitstatus, child.signalstatus)
    else:
        assert child.exitstatus is not None and child.exitstatus != 0
  '';
in
testers.runNixOSTest {
  name = "nixos-cli";

  defaults = { lib, ... }: {
    environment.etc."nixos-cli-generation".text = "A\n";
    specialisation.generationB.configuration = {
      environment.etc."nixos-cli-generation".text = lib.mkForce "B\n";
    };
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };
    users.users.root.openssh.authorizedKeys.keys = [ keys.snakeOilEd25519PublicKey ];
    # Keep failure cases independent of any previous sudo authentication.
    security.sudo.extraConfig = ''
      Defaults timestamp_timeout=0,passwd_tries=1
    '';
    virtualisation.memorySize = 768;
    # Source-based rebuilds also copy the pinned nixpkgs source to the target.
    virtualisation.diskSize = 4096;
    virtualisation.writableStoreUseTmpfs = false;
  };

  nodes = {
    deployer = { nodes, ... }: {
      environment.systemPackages = [
        command
        python
      ];
      users.users.operator = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      security.sudo.wheelNeedsPassword = false;
      system.includeBuildDependencies = true;
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = lib.mkForce [ ];
      };
      virtualisation.memorySize = lib.mkForce 3072;
      virtualisation.cores = 2;
      # Register prebuilt remote systems locally; nixos-rebuild still performs
      # the real store copy, profile update and activation over SSH.
      virtualisation.additionalPaths = [
        path
      ]
      ++ map (name: nodes.${name}.system.build.toplevel) [
        "rootTarget"
        "sudoTarget"
        "passwordTarget"
      ];
      programs.ssh.extraConfig = ''
        Host *
          IdentityFile /etc/nixos-cli-test-key
          StrictHostKeyChecking no
          UserKnownHostsFile /dev/null
          BatchMode yes
          ConnectTimeout 5
      '';
      system.activationScripts.nixos-cli-test-key.text = ''
        install -m 0600 ${keys.snakeOilEd25519PrivateKey} /etc/nixos-cli-test-key
      '';
    };
    rootTarget = { };
    sudoTarget = {
      users.users.operator = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ keys.snakeOilEd25519PublicKey ];
      };
      security.sudo.wheelNeedsPassword = false;
    };
    passwordTarget = {
      users.users.operator = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        password = "test-only-password";
        openssh.authorizedKeys.keys = [ keys.snakeOilEd25519PublicKey ];
      };
      security.sudo.wheelNeedsPassword = true;
    };
  };

  testScript =
    { nodes, ... }:
    let
      flake = ''
        {
          inputs.nixpkgs.url = "path:${path}";
          inputs.cli = { url = "path:${command}"; flake = false; };
          inputs.python = { url = "path:${python}"; flake = false; };
          outputs = { nixpkgs, cli, python, ... }: {
            nixosConfigurations = nixpkgs.lib.genAttrs [ "deployer" "rootTarget" ] (name:
              nixpkgs.lib.nixosSystem {
                system = "${command.system}";
                modules = [
                  ({ modulesPath, ... }: {
                    imports = [
                      (modulesPath + "/virtualisation/qemu-vm.nix")
                      (modulesPath + "/../lib/testing/nixos-test-base.nix")
                    ];
                    system.switch.enable = true;
                    # The test VM's root disk has no partition table.
                    boot.loader.grub.forceInstall = true;
                    virtualisation.writableStoreUseTmpfs = false;
                  })
                  (nixpkgs.lib.modules.importJSON (./. + "/''${name}.json"))
                  {
                    environment.systemPackages = nixpkgs.lib.optionals (name == "deployer") [
                      cli.outPath
                      python.outPath
                    ];
                  }
                ];
              });
          };
        }
      '';
      sourceConfigs = lib.genAttrs [ "deployer" "rootTarget" ] (
        name:
        lib.recursiveUpdate nodes.${name}.system.build.networkConfig {
          networking.hostName = name;
          system.stateVersion = nodes.${name}.system.stateVersion;
          environment.etc."nixos-cli-generation".text = "B\n";
          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "prohibit-password";
              PasswordAuthentication = false;
            };
          };
          users.users = {
            root.openssh.authorizedKeys.keys = [ keys.snakeOilEd25519PublicKey ];
          }
          // lib.optionalAttrs (name == "deployer") {
            operator = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
            };
          };
          security.sudo = {
            wheelNeedsPassword = false;
            extraConfig = "Defaults timestamp_timeout=0,passwd_tries=1";
          };
          programs.ssh.extraConfig = lib.optionalString (
            name == "deployer"
          ) nodes.deployer.programs.ssh.extraConfig;
          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            substituters = [ ];
          };
        }
      );
    in
    ''
      import json
      import shlex

      start_all()
      guests = {
          "deployer": deployer,
          "rootTarget": rootTarget,
          "sudoTarget": sudoTarget,
          "passwordTarget": passwordTarget,
      }
      generation_a = {
          ${lib.concatMapStringsSep "\n" (name: ''"${name}": "${nodes.${name}.system.build.toplevel}",'')
            [
              "deployer"
              "rootTarget"
              "sudoTarget"
              "passwordTarget"
            ]
          }
      }
      generation_b = {name: a + "/specialisation/generationB" for name, a in generation_a.items()}
      # Resolve B's store path, since /run/current-system and profiles are canonical.
      for name, machine in guests.items():
          machine.wait_for_unit("multi-user.target")
          machine.wait_for_unit("sshd.service")
          generation_b[name] = machine.succeed("readlink -f " + generation_b[name]).strip()
      for name in ["rootTarget", "sudoTarget", "passwordTarget"]:
          deployer.succeed("ssh root@" + name + " true", timeout=15)

      deployer.succeed("mkdir -p /etc/nixos /tmp/nixos-cli-empty")
      flake_source = ${builtins.toJSON flake}
      deployer.succeed("printf %s " + shlex.quote(flake_source) + " > /etc/nixos/flake.nix")
      source_configs = ${builtins.toJSON (builtins.toJSON sourceConfigs)}
      for name, config in json.loads(source_configs).items():
          deployer.succeed("printf %s " + shlex.quote(json.dumps(config)) + " > /etc/nixos/" + name + ".json")
      source_generation_b = {
          name: deployer.succeed(
              "nix eval --raw /etc/nixos#nixosConfigurations." + name + ".config.system.build.toplevel.outPath",
              timeout=240,
          ).strip()
          for name in ["deployer", "rootTarget"]
      }

      def assert_state(selected=None, action=None, updated=None):
          updated = generation_b if updated is None else updated
          for name, machine in guests.items():
              active = updated[name] if name == selected else generation_a[name]
              profile = updated[name] if name == selected and action == "switch" else generation_a[name]
              assert machine.succeed("readlink -f /run/current-system").strip() == active, name
              assert machine.succeed("cat /etc/nixos-cli-generation").strip() == ("B" if name == selected else "A"), name
              assert machine.succeed("readlink -f /nix/var/nix/profiles/system").strip() == profile, name

      def reset():
          for name, machine in guests.items():
              a = generation_a[name]
              machine.succeed("nix-env -p /nix/var/nix/profiles/system --set " + a)
              machine.succeed(a + "/bin/switch-to-configuration test")
          assert_state()

      def invocation(selected, action, host=None, extra=()):
          return shlex.join(["nixos", *([host] if host else []), action,
                             "--no-reexec", "--store-path", generation_b[selected], *extra])

      def password_run(command, password, expected):
          deployer.succeed(shlex.join([
              "${python}/bin/python", "${passwordDriver}", password, expected,
              *shlex.split(command),
          ]), timeout=240)

      for command_line, selected, action in [
          ("nixos switch", "deployer", "switch"),
          ("nixos deployer switch", "deployer", "switch"),
          ("nixos rootTarget switch", "rootTarget", "switch"),
          ("nixos test", "deployer", "test"),
          ("nixos rootTarget test", "rootTarget", "test"),
      ]:
          with subtest(command_line):
              reset()
              assert deployer.succeed("find /tmp/nixos-cli-empty -mindepth 1 -maxdepth 1") == ""
              deployer.succeed("cd /tmp/nixos-cli-empty && " + command_line, timeout=180)
              assert deployer.succeed("find /tmp/nixos-cli-empty -mindepth 1 -maxdepth 1") == ""
              assert_state(selected, action, source_generation_b)

      for action in ["switch", "test"]:
          with subtest(f"local unprivileged user {action}"):
              reset()
              deployer.succeed("su - operator -c " + shlex.quote(invocation("deployer", action)), timeout=180)
              assert_state("deployer", action)

          for name in ["sudoTarget", "passwordTarget"]:
              with subtest(f"named {name} {action}"):
                  reset()
                  cmd = invocation(name, action, name)
                  if name == "passwordTarget":
                      password_run(cmd, "test-only-password", "success")
                  else:
                      deployer.succeed(cmd, timeout=180)
                  assert_state(name, action)

          with subtest(f"explicit target overrides catalog access and password policy {action}"):
              reset()
              deployer.succeed(invocation("rootTarget", action, "passwordTarget", ["--target-host=root@rootTarget"]), timeout=180)
              assert_state("rootTarget", action)

          with subtest(f"exhausted sudo password attempts {action}"):
              reset()
              password_run(invocation("passwordTarget", action, "passwordTarget"), "wrong-password", "failure")
              assert_state()

          with subtest(f"SSH access denied {action}"):
              reset()
              deployer.fail(invocation("rootTarget", action, "rootTarget", ["--target-host", "denied@rootTarget"]), timeout=180)
              assert_state()
    '';
}
