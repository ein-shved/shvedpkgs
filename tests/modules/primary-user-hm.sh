#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

fixture=tests/modules/primary-user-hm.nix
logdir=${PRIMARY_USER_HM_LOG_DIR:-$(mktemp -d)}
mkdir -p "$logdir"
echo "Validation evidence: $logdir"

check() {
  local name=$1
  echo "+ nix eval --impure --json --file $fixture $name"
  if ! nix eval --impure --json --file "$fixture" "$name" \
      > "$logdir/$name.json" 2> "$logdir/$name.stderr"; then
    cat "$logdir/$name.stderr" >&2
    echo "FAIL $name: expected successful evaluation" >&2
    exit 1
  fi
  jq -r 'to_entries[] | "\(.key): expected true, observed \(.value)"' \
    "$logdir/$name.json"
  jq -e 'all(.[]; . == true)' "$logdir/$name.json" > /dev/null
  echo "$name: exit 0"
}

reject() {
  local name=$1 diagnostic=$2
  echo "+ nix eval --impure --json --file $fixture $name"
  if nix eval --impure --json --file "$fixture" "$name" \
      > "$logdir/$name.json" 2> "$logdir/$name.stderr"; then
    echo "FAIL $name: expected evaluation failure" >&2
    exit 1
  else
    local status=$?
    echo "$name: expected failure, observed exit $status"
  fi
  if ! rg -q -- "$diagnostic" "$logdir/$name.stderr"; then
    cat "$logdir/$name.stderr" >&2
    echo "FAIL $name: missing diagnostic $diagnostic" >&2
    exit 1
  fi
  for source in "${@:3}"; do
    if ! rg -q -- "In .*$source" "$logdir/$name.stderr"; then
      cat "$logdir/$name.stderr" >&2
      echo "FAIL $name: missing definition source $source" >&2
      exit 1
    fi
  done
}

check accountChecks
for field in name humanName home domainName; do
  reject "missing.$field" "option .user.name.*no value defined"
done

if [[ ${1:-} != --account-home-only ]]; then
  check consumerChecks
  check transmissionChecks
  reject transmissionMissingLogin 'option .user.name.*no value defined'
  for name in printing vpn media cntlm kl domain; do
    reject "consumerErrors.$name" 'option .user.name.*no value defined'
  done
  for name in dmRead dmAccountOnly dmTheme; do
    reject "consumerErrors.$name" 'primary Home Manager environment is not active'
  done
fi

check homeChecks
reject homeErrors.missingLogin 'home.enable requires a configured user.name'
reject homeErrors.conflict 'home.stateVersion.*conflicting definition' \
  'fixtures/primary-user-hm/alias-errors\.nix' \
  'fixtures/primary-user-hm/direct-conflict\.nix'
for name in readNoLogin readAccountOnly readSecondary readIndependentPrimary; do
  reject "homeErrors.$name" 'primary Home Manager environment is not active'
done
reject homeErrors.nestedThrow 'deferred nested value applied'
reject homeErrors.moduleThrow 'deferred module body applied'
reject homeErrors.invalidValue 'programs.git.enable.*not of type' \
  'fixtures/primary-user-hm/alias-errors\.nix'

echo "+ nix eval --impure --json --file $fixture refreshActivation"
nix eval --impure --json --file "$fixture" refreshActivation \
  > "$logdir/refreshActivation.json"
for mode in enabled disabled; do
  drv=$(jq -r --arg mode "$mode" '.[$mode]' \
    "$logdir/refreshActivation.json")
  echo "+ nix derivation show $drv"
  nix derivation show "$drv" > "$logdir/refresh-$mode.drv.json"
  script_drv=$(jq -r '(.derivations // .)[] |
    (.inputs.drvs // .inputDrvs) | keys[] |
    select(endswith("-activation-script.drv")) |
    if startswith("/") then . else "/nix/store/" + . end' \
    "$logdir/refresh-$mode.drv.json")
  nix derivation show "$script_drv" \
    | jq -r '(.derivations // .)[].env.text' \
    > "$logdir/refresh-$mode.sh"
done
rg -q 'manifest.json' "$logdir/refresh-enabled.sh"
rg -q 'nix profile add' "$logdir/refresh-enabled.sh"
if rg -q 'preInstallPackages' "$logdir/refresh-disabled.sh"; then
  echo 'FAIL refresh: disabled script contains preInstallPackages' >&2
  exit 1
fi
before=$(rg -n 'Activating.*"preInstallPackages"' \
  "$logdir/refresh-enabled.sh" | cut -d: -f1)
after=$(rg -n 'Activating.*"installPackages"' \
  "$logdir/refresh-enabled.sh" | cut -d: -f1)
[[ "$before" -lt "$after" ]]
echo 'refresh script: expected step before installPackages; observed matching script'

if [[ ${1:-} == --focused || ${1:-} == --account-home-only ]]; then
  exit 0
fi

echo '+ nix eval --impure --json --file tests/modules/primary-user-hm-hosts.nix'
nix eval --impure --json --file tests/modules/primary-user-hm-hosts.nix \
  > "$logdir/hosts.json" 2> "$logdir/hosts.stderr"
jq -e 'all(.[]; .homeEnabled and .account.isNormalUser
  and .account.createHome and .hm.useGlobalPkgs
  and .hm.username == .login and .hm.homeDirectory == .account.home)' \
  "$logdir/hosts.json" > /dev/null
jq 'map_values({login, homeEnabled, hm})' "$logdir/hosts.json"

for host in ShvedGaming ShvedMedia gerrit testA testB testNas testVps; do
  target=".#nixosValidationConfigurations.$host.config.system.build.toplevel"
  echo "+ nix eval --raw --no-write-lock-file $target.drvPath"
  nix eval --raw --no-write-lock-file "$target.drvPath" \
    > "$logdir/$host.drvPath" 2> "$logdir/$host.eval.stderr"
  echo "$host toplevel: exit 0; $(cat "$logdir/$host.drvPath")"
  echo "+ nix build --dry-run --no-link --no-write-lock-file $target"
  if ! nix build --dry-run --no-link --no-write-lock-file "$target" \
      > "$logdir/$host.build.stdout" 2> "$logdir/$host.build.stderr"; then
    cat "$logdir/$host.build.stderr" >&2
    echo "FAIL $host: build planning failed" >&2
    exit 1
  fi
  echo "$host build planning: exit 0"
done
