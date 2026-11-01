{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.pass;
  passExt = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  key = "${cfg.gpgid}/gpg.id";
  hasKey = cfg.gpgid != null;
  hasRemote = cfg.giturl != null;

  passSetupScript = pkgs.writeShellApplication {
    name = "pass-setup";
    runtimeInputs = [
      pkgs.gnupg
      pkgs.pass
      pkgs.gawk
      pkgs.git
    ];
    text = ''
      passKeyFingerprint="$(gpg --batch --with-colons \
        --import-options show-only --import "${key}" | \
        awk -F: \
          '$1 == "fpr" && !found { print $10; found = 1 }')"
      if [ -z "$passKeyFingerprint" ]; then
        echo "pass: the supplied GPG key has no fingerprint" >&2
        exit 1
      fi
      if ! gpg --batch --with-colons \
        --list-secret-keys "$passKeyFingerprint" 2>/dev/null | \
        awk -F: \
          '$1 == "sec" { found = 1 } END { exit !found }'; then
        gpg --batch --import "${key}"
      fi
    ''
    + lib.optionalString hasRemote ''
      if ! pass git rev-parse --git-dir >/dev/null 2>&1; then
        git clone -- ${lib.escapeShellArg cfg.giturl} \
          "''${PASSWORD_STORE_DIR:-$HOME/.password-store}"
      fi
    '';
  };

  passSetupService = {
    Unit = {
      Description = "Prepare the user's pass key and repository";
      After = [ "sockets.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Start GPG only after the user manager has created runtime sockets.
      ExecStart = lib.getExe passSetupScript;
    };
    Install.WantedBy = [ "default.target" ];
  };
in
{
  options = with lib; {
    programs.pass = {
      enable = mkEnableOption "Whether to deploy gnupass db";
      gpgid = mkOption {
        type = types.nullOr types.package;
        description = "Package with gpg.id file in out path";
        default = null;
      };
      giturl = mkOption {
        type = types.nullOr types.str;
        description = "Url of git repo for gnupass";
        default = null;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ passExt ];
    hm.systemd.user.services.pass-setup = lib.mkIf hasKey passSetupService;
    programs.gnupg.agent.enable = true;
  };
}
