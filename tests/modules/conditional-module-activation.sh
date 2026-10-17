#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

fixture=tests/modules/conditional-module-activation.nix
logdir=${CONDITIONAL_MODULE_LOG_DIR:-$(mktemp -d)}
mkdir -p "$logdir"
echo "Validation evidence: $logdir"

check() {
  local name=$1
  echo "+ nix eval --impure --json --file $fixture $name"
  if ! nix eval --impure --json --file "$fixture" "$name" \
      > "$logdir/$name.json" 2> "$logdir/$name.stderr"; then
    cat "$logdir/$name.stderr" >&2
    exit 1
  fi
  jq -r 'to_entries[] | "\(.key): expected true, observed \(.value)"' "$logdir/$name.json"
  jq -e 'all(.[]; . == true)' "$logdir/$name.json" > /dev/null
  echo "$name: exit 0"
}

reject() {
  local name=$1 diagnostic=$2
  echo "+ nix eval --impure --json --file $fixture $name"
  if nix eval --impure --json --file "$fixture" "$name" \
      > "$logdir/$name.json" 2> "$logdir/$name.stderr"; then
    echo "FAIL $name: expected failure" >&2
    exit 1
  else
    echo "$name: expected failure, observed exit $?"
  fi
  if ! rg -q -- "$diagnostic" "$logdir/$name.stderr"; then
    cat "$logdir/$name.stderr" >&2
    echo "FAIL $name: missing diagnostic $diagnostic" >&2
    exit 1
  fi
}

run_group() {
  check "$1"
  case $1 in
    hardware) reject errors.standbyTimeout 'standby.timeout.*no value defined' ;;
    services)
      reject errors.gerritDomain 'services.vps.domain.*no value defined'
      reject errors.gerritServerId 'services.gerrit.serverId.*no value defined'
      ;;
  esac
}
case ${1:-all} in
  all) for group in hardware kl services formats collection hosts; do run_group "$group"; done ;;
  hardware|kl|services|formats|collection|hosts) run_group "$1" ;;
  *) echo "Unknown group: $1" >&2; exit 2 ;;
esac
