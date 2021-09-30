{ config, pkgs, lib, ... }:
let
  cfg = config.local.gnupass;
in {
  options = with lib; {
    local.gnupass = {
      enable = mkEnableOption "Whether to deploy gnupass db";
      gpgid = mkOption {
        type = types.package;
          description = "Package with gpg.id file in out path";
      };
      giturl = mkOption {
        type = types.str;
        description = "Url of git repo for gnupass";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.pass
    ];
    local.activations = {
      preparePassDb = let
        key = "${cfg.gpgid}/gpg.id";
        pass = "${pkgs.pass}/bin/pass";
      in ''
        set -e;
        k=$(gpg2 --import-options show-only \
            --list-options show-notations \
            --import "${key}" | grep -v '^\S' | xargs)
        gpg2 -K "$k" 2>/dev/null >/dev/null || \
          gpg2 --import "${key}"
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
    programs = {
      gnupg.agent.enable = true;
    };
  };
}
