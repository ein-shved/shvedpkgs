# nix build .#tests.codex
{
  pkgs,
  lib,
  callPackage,
  linkFarm,
  writeText,
}:
let
  evaluate =
    modules:
    (import "${pkgs.path}/nixos/lib/eval-config.nix" {
      system = pkgs.stdenv.hostPlatform.system;
      modules = [
        ../../../modules/services/codex
        {
          nixpkgs.pkgs = pkgs;
          system.stateVersion = "26.05";
          users.users.developer = {
            isNormalUser = true;
            home = "/home/developer";
          };
        }
      ]
      ++ modules;
    }).config;
  enabled = evaluate [
    {
      services.codex = {
        enable = true;
        user = "developer";
      };
    }
  ];
  disabled = evaluate [ { } ];
  missingUser = evaluate [ { services.codex.enable = true; } ];
  inheritedInvalidHome = evaluate [
    {
      users.users.serviceUser = {
        isSystemUser = true;
        group = "serviceUser";
      };
      users.groups.serviceUser = { };
      services.codex = {
        enable = true;
        user = "serviceUser";
      };
    }
  ];
  explicitHome = evaluate [
    {
      users.users.serviceUser = {
        isSystemUser = true;
        group = "serviceUser";
      };
      users.groups.serviceUser = { };
      services.codex = {
        enable = true;
        user = "serviceUser";
        home = "/srv/codex";
      };
    }
  ];
  custom = evaluate [
    {
      services.codex = {
        enable = true;
        user = "developer";
        package = pkgs.hello;
        home = "/home/custom";
        codexHome = "/home/custom/state";
        socketPath = "/home/custom/socket with spaces%$";
        remoteControl.enable = true;
      };
    }
  ];
  invalid = evaluate [
    {
      services.codex = {
        enable = true;
        user = "missing";
      };
    }
  ];
  invalidHome = evaluate [
    {
      services.codex = {
        enable = true;
        user = "developer";
        home = "relative";
      };
    }
  ];
  policy =
    development: extra:
    evaluate (
      [
        ../../../config/services/codex
        ({ lib, ... }: {
          options.hardware.development = lib.mkOption {
            type = lib.types.bool;
            default = development;
          };
          options.user.name = lib.mkOption {
            type = lib.types.str;
            default = "developer";
          };
          options.user.home = lib.mkOption {
            type = lib.types.str;
            default = "/home/developer";
          };
        })
      ]
      ++ extra
    );
  dev = policy true [ ];
  nonDev = policy false [ ];
  overridden = policy true [ { services.codex.enable = lib.mkForce false; } ];
  explicit = policy false [
    {
      services.codex = {
        enable = true;
        user = "developer";
      };
    }
  ];
  unit = enabled.systemd.services.codex;
  checks = {
    disabled =
      !(disabled.systemd.services ? codex)
      && !(builtins.elem pkgs.codex disabled.environment.systemPackages);
    packageInstalled = builtins.elem pkgs.codex enabled.environment.systemPackages;
    foregroundCommand =
      unit.serviceConfig.ExecStart == ''"${pkgs.codex}/bin/codex" "app-server" "--listen" "unix://"'';
    remoteDisabled = !enabled.services.codex.remoteControl.enable;
    identity =
      unit.serviceConfig.User == "developer" && unit.serviceConfig.WorkingDirectory == "/home/developer";
    environment =
      unit.environment.HOME == "/home/developer"
      && unit.environment.CODEX_HOME == "/home/developer/.codex";
    boot =
      builtins.elem "multi-user.target" unit.wantedBy
      && builtins.elem "network-online.target" unit.after
      && builtins.elem "network-online.target" unit.wants;
    mounts =
      unit.unitConfig.RequiresMountsFor == [
        "/home/developer"
        "/home/developer/.codex"
      ];
    restart =
      unit.serviceConfig.Type == "simple"
      && unit.serviceConfig.Restart == "on-failure"
      && unit.serviceConfig.RestartSec == "5s";
    customPackage =
      builtins.elem pkgs.hello custom.environment.systemPackages
      && lib.hasPrefix ''"${pkgs.hello}/bin/hello" '' custom.systemd.services.codex.serviceConfig.ExecStart;
    customEnvironment = custom.systemd.services.codex.environment.CODEX_HOME == "/home/custom/state";
    customSocketEscaping = lib.hasInfix ''"--remote-control" "--listen" "unix:///home/custom/socket with spaces%%$$"'' custom.systemd.services.codex.serviceConfig.ExecStart;
    invalidUser = builtins.any (
      a: !a.assertion && lib.hasPrefix "services.codex.user" a.message
    ) invalid.assertions;
    invalidHome = !(builtins.tryEval invalidHome.services.codex.home).success;
    requiredUser = !(builtins.tryEval missingUser.services.codex.user).success;
    inheritedHomeValidation = builtins.any (
      a: !a.assertion && lib.hasPrefix "services.codex.home" a.message
    ) inheritedInvalidHome.assertions;
    explicitHomeValidation = builtins.all (
      a: a.assertion || !(lib.hasPrefix "services.codex." a.message)
    ) explicitHome.assertions;
    development =
      dev.services.codex.enable
      && dev.services.codex.remoteControl.enable
      && dev.services.codex.user == "developer";
    nonDevelopment = !(nonDev.systemd.services ? codex);
    override =
      !(overridden.systemd.services ? codex)
      && !(builtins.elem pkgs.codex overridden.environment.systemPackages);
    explicitNonDevelopment = explicit.systemd.services ? codex;
  };
in
assert lib.assertMsg (builtins.all (x: x) (
  builtins.attrValues checks
)) "Codex module evaluation checks failed";
linkFarm "codex-tests" [
  {
    name = "evaluation.json";
    path = writeText "codex-module-evaluation.json" (builtins.toJSON checks);
  }
  {
    name = "vm";
    path = callPackage ./vm.nix { };
  }
]
