{ lib, ... }:
lib.mkOverlay (
  { git, writeShellApplication, ... }:
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
        [ -z "$BRANCH" ] && BRANCH="$PREV"
        [ -z "$BRANCH" ] && echo "Invalid revision $PREV" && exit 1
        START="$(git log --reverse --ancestry-path --pretty=format:"%h" \
          --no-patch "HEAD^..$BRANCH" | head -1)"

        git rebase --onto HEAD "$START" "$BRANCH"

        $DOPOP
      '';
    };

    gcme = noedit:
      let
        name = if noedit then "gcmnu" else "gcmu";
        op = if noedit then "--no-edit" else "";
      in
      writeShellApplication {
        inherit name;
        runtimeInputs = [ git ];
        text = ''
          set -e
          git commit --amend ${op} "$@"
          ${gitupdate}/bin/gitupdate
        '';
      };

    gcmnu = gcme true;
    gcmu = gcme false;

  in
  { inherit gitupdate gcmu gcmnu; }
)

