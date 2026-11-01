{ writeShellScriptBin }:
# Isolate GPG's session lifecycle from graphical passphrase entry.
writeShellScriptBin "pinentry" ''
  echo OK
  while read -r command rest; do
    case "$command" in
      GETPIN) echo 'D fixture-passphrase'; echo OK ;;
      BYE) echo OK; exit 0 ;;
      *) echo OK ;;
    esac
  done
''
