{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.services.codex;
  absolutePath = lib.types.strMatching "/.*";
  account = config.users.users.${cfg.user};
  listener = if cfg.socketPath == null then "unix://" else "unix://${cfg.socketPath}";
in
{
  options.services.codex = {
    enable = lib.mkEnableOption "the shared Codex app-server";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.codex;
      defaultText = lib.literalExpression "pkgs.codex";
      description = "Codex package installed system-wide and used by the service.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      description = "Existing local account running the app-server.";
    };
    home = lib.mkOption {
      type = absolutePath;
      default = account.home;
      defaultText = lib.literalExpression "config.users.users.<user>.home";
      description = "Home directory and working directory of the service.";
    };
    codexHome = lib.mkOption {
      type = absolutePath;
      default = "${cfg.home}/.codex";
      defaultText = lib.literalExpression ''"''${config.services.codex.home}/.codex"'';
      description = "Directory containing user-owned Codex state and authentication.";
    };
    socketPath = lib.mkOption {
      type = lib.types.nullOr absolutePath;
      default = null;
      description = "Unix socket path; null uses Codex's standard control socket. A custom parent must already exist and be writable by the service user.";
    };
    remoteControl.enable = lib.mkEnableOption "Codex's outbound remote-control transport";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.users.users ? ${cfg.user};
        message = "services.codex.user must name an existing local account.";
      }
      {
        assertion = !(config.users.users ? ${cfg.user}) || cfg.home != "/var/empty";
        message = "services.codex.home must be a usable home directory.";
      }
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.services.codex = {
      description = "Shared Codex app-server";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [
        cfg.home
        cfg.codexHome
      ];
      path = [ "/run/current-system/sw" ];
      environment = {
        HOME = cfg.home;
        CODEX_HOME = cfg.codexHome;
      };
      # An explicit CODEX_HOME must exist even before the user's first login.
      preStart = ''
        ${pkgs.coreutils}/bin/mkdir -p -- ${lib.escapeShellArg cfg.codexHome}
      '';
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.home;
        ExecStart = utils.escapeSystemdExecArgs (
          [
            (lib.getExe cfg.package)
            "app-server"
          ]
          ++ lib.optional cfg.remoteControl.enable "--remote-control"
          ++ [
            "--listen"
            listener
          ]
        );
        Restart = "on-failure";
        RestartSec = "5s";
        KillSignal = "SIGTERM";
        StandardOutput = "journal";
        StandardError = "journal";
      };
    };
  };
}
