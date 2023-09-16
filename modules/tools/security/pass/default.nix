{ config, pkgs, lib, ... }:
let
  cfg = config.programs.pass;
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
  config = let
      passExt = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  in lib.mkIf cfg.enable {
    environment.systemPackages = [
      passExt
    ];
    home.activations =
      let
        key = "${cfg.gpgid}/gpg.id";
        pass = "${pkgs.pass}/bin/pass";
        hasKey = cfg.gpgid != null;
        hasRemote = cfg.giturl != null;
        gpg2 = "${pkgs.gnupg}/bin/gpg";
        keyHash = ''
          k="$(${gpg2} --import-options show-only \
              --list-options show-notations \
              --import "${key}" | grep -v '^\S' | xargs)"
        '';
      in
      {
        installPassGpgKey = if !hasKey then "true" else ''
          ${keyHash}
          ${gpg2} -K "$k" 2>/dev/null >/dev/null || \
            ${gpg2} --import "${key}"
        '';
        preparePassDb = {
          after = "installPassGpgKey";
          script = if !hasRemote || !hasKey then "true" else ''
            ${keyHash}

            u="${cfg.giturl}"
            r="$(${pass} git remote -v)" && exit 0;
            ${pass} init "$k"
            ${pass} git init -b master
            ${pass} git checkout -b _stash
            ${pass} git commit -m _stash
            ${pass} git remote add origin "$u"
            ${pass} git checkout master
            ${pass} git branch --set-upstream-to origin/master
            ${pass} git pull --rebase=true origin master
          '';
        };
      };
    programs = {
      gnupg.agent.enable = true;
    };
  };
}

