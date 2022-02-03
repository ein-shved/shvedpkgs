{ pkgs, ... }:
let
  # Run editwork [<workname>] [EDITOR ARGS ...] to edit or create work name
  # inside <workname>.sh
  #
  # Run dowork [<workname>] [EDITOR ARGS ...] to run work with <workname>
  #
  # Run listwork to show all available works
  #
  # Run flushwork <workname> [ <workname> ...] to remove specified works
  #
  # Without arguments scripts uses latest edited or executed work
  prepareWork = pkgs.writeShellScriptBin "preparework" ''
    worksPath=$HOME/.local/share/work

    mkdir -p "$worksPath";

    function getLastFilePath() {
      unset -v latest
      for file in "$worksPath"/*; do
        [[ "$file" -nt "$latest" ]] && latest="$file"
      done
      test -z "$latest" && echo "There no any work written" >&2 && return
      echo "$latest"
    }

    function getFilePath() {
      name="$1";
      test -z "$name" || test "$name" == "--" && { getLastFilePath; return; }
      filePath="$worksPath/$name"
      test -f "$filePath" && echo "$filePath" && return
      echo "$filePath.sh"
    }

    function getWorkName() {
      file="$1";
      filename="$(basename -- "$file")"
      name="''${filename%.*}"
      echo -n "$name"
    }

  '';

  sourcePrepare = "source ${prepareWork}/bin/preparework";

  doWork = pkgs.writeShellScriptBin "dowork" ''
    ${sourcePrepare}

    name="$1";
    shift;
    work="$(getFilePath "$name")"
    workname="$(getWorkName $work)"
    test -x "$work" && \
      echo "Running work $workname $@" && \
      touch -c "$work" && \
      WORKNAME="$workname" exec "$work" "$@"
    test -n "$work" && echo "Can not execute work at '$work'"
  '';

  editWork = pkgs.writeShellScriptBin "editwork" ''
    ${sourcePrepare}

    name="$1";
    shift;
    EDITOR="''${EDITOR-vim}"
    work="$(getFilePath "$name")"
    workname="$(getWorkName $work)"
    test -n "$work" && WORKNAME="$workname" $EDITOR "$work" "$@" && \
      touch -c "$work" && \
      exec chmod +x "$work"
  '';

  listWorks = pkgs.writeShellScriptBin "listworks" ''
    ${sourcePrepare}

    len=0
    for file in "$worksPath"/*; do
      name="$(getWorkName $file)"
      nl="''${#name}"
      [[ $nl -gt $len ]] && len=$nl;
    done

    for file in "$worksPath"/*; do
      name="$(getWorkName $file)"
      printf '\t%-'$len's\t%s\n' $name $file
    done
  '';

  flushWork = pkgs.writeShellScriptBin "flushwork" ''
    ${sourcePrepare}

    [ -z "$1" ] && \
      echo "You must provide at least one work to remove" >&2 && \
      exit 1
    files=
    while [ -n "$1" ]; do
      name="$1"
      shift
      file="$(getFilePath "$name")"
      [ -z "$file" ] && \
        echo "No such work: '$1'" >&2 && \
        exit 1;
      files="$files $file"
    done
    echo "Removing $files"
    exec rm $files;
  '';

  workCompletions = ''
    ${sourcePrepare}

    function _works()
    {
        local names file cur
        COMPREPLY=()
        cur="''${COMP_WORDS[COMP_CWORD]}"
        if [[ $COMP_CWORD != 1 ]]; then
          COMPREPLY=( $(compgen -W "*" -- ''${cur}) )
          return 0
        fi

        for file in "$worksPath"/*; do
          names="$names $(getWorkName $file)"
        done

        if [[ -n "$names" ]] ; then
            COMPREPLY=( $(compgen -W "''${names}" -- ''${cur}) )
            return 0
        fi
    }
    complete -F _works dowork
    complete -F _works editwork
    complete -F _works flushwork
  '';

in {
  config = {
    environment.systemPackages = [
        doWork
        editWork
        listWorks
        flushWork
    ];
    programs.bash.extraCompletions = [
      workCompletions
    ];
  };
}
