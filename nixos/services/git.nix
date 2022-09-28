{ config, pkgs, lib, ... }:
let
  git = "${pkgs.git}/bin/git";
  gitupdate = pkgs.writeShellScriptBin "gitupdate" ''
    set -e

    PREV="''${1-"@{-1}"}"
    BRANCH="$(${git} rev-parse --abbrev-ref @{-1})"
    [ -z "$BRANCH" ] && BRANCH="$PREV"
    [ -z "$BRANCH" ] && echo "Invalid revision $PREV" && exit 1
    START="$(${git} log --reverse --ancestry-path --pretty=format:"%h" \
      --no-patch "HEAD^..$BRANCH" | head -1)"

    exec ${git} rebase --onto HEAD $START $BRANCH
  '';
  gcme = noedit: let
    name = if noedit then "gcmnu" else "gcmu";
    op = if noedit then "--no-edit" else "";
  in pkgs.writeShellScriptBin name ''
    set -e
    ${git} commit --amend ${op} "$@"
    DOPOP="true"
    if [ "$(${git} diff --stat)" != "" ]; then
      DOPOP="${git} stash pop"
      ${git} stash
    fi
    ${gitupdate}/bin/gitupdate
    $DOPOP
  '';
  gcmnu = gcme true;
  gcmu = gcme false;

in
{
  config = {
    local.extras = (pkgs.mkLocalExtra "programs" {
      git = lib.mkIf (config.local.user.mail != null) {
        enable = true;
        lfs.enable = true;
        package = pkgs.gitFull;
        userName = config.local.user.name;
        userEmail = config.local.user.mail;
        includes = [{
          contents = {
            pull = {
              rebase = true;
            };
            fetch = {
              prune = true;
            };
            diff = {
              colorMoved = "zebra";
            };
            http = {
              version = "HTTP/1.1";
            };
          };
        }];
      };
    });
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
    environment.systemPackages = [
      pkgs.git-review
      gitupdate
      gcmnu
      gcmu
    ];
  };
}
