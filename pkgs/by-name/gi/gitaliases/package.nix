{
  git,
  writeShellApplication,
  symlinkJoin,
}:
let
  gitupdate = writeShellApplication {
    name = "gitupdate";
    runtimeInputs = [ git ];
    text = ''
      set -e

      DOPOP="true"

      if [ "$(git diff --stat)" != "" ]; then
        DOPOP="git stash pop"
        git stash
      fi

      PREV="''${1-'@{-1}'}"
      BRANCH="$(git rev-parse --abbrev-ref '@{-1}')"
      if [ -z "$BRANCH" ]; then
        BRANCH="$PREV"
      fi
      if [ -z "$BRANCH" ]; then
        echo "Invalid revision $PREV"
        exit 1
      fi
      LOG="$(git log --reverse --ancestry-path --pretty=format:"%h" \
             --no-patch "HEAD^..$BRANCH")"
      START="$(echo "$LOG" | head -n1)"

      git rebase --onto HEAD "$START" "$BRANCH"

      $DOPOP
    '';
  };

  gcme =
    noedit:
    let
      name = if noedit then "gcmnu" else "gcmu";
      op = if noedit then "--no-edit" else "";
    in
    writeShellApplication {
      inherit name;
      runtimeInputs = [
        git
        gitupdate
      ];
      text = ''
        set -e
        git commit --amend ${op} "$@"
        exec gitupdate
      '';
    };

  gcmnu = gcme true;
  gcmu = gcme false;

in
symlinkJoin {
  name = "gitaliases";
  paths = [
    gitupdate
    gcmu
    gcmnu
  ];
}
