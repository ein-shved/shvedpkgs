#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'usage: %s <artifact> [specs-root]\n' "${0##*/}" >&2
  printf 'artifact must be one of: requirements, system, verify, inventory, adrs\n' >&2
}

artifact="${1:-}"
root="${2:-specs}"

case "$artifact" in
  requirements|system|verify|inventory|adrs) ;;
  *)
    usage
    exit 64
    ;;
esac

if [[ ! -d "$root" ]]; then
  printf 'specs root does not exist: %s\n' "$root" >&2
  exit 66
fi

first=1
while IFS= read -r -d '' dir; do
  file="$dir/$artifact.md"
  [[ -f "$file" ]] || continue

  if [[ "$first" -eq 0 ]]; then
    printf '\n'
  fi
  first=0

  printf '<!-- source: %s -->\n\n' "$file"
  sed -n '1,$p' "$file"
done < <(find "$root" -mindepth 1 -maxdepth 1 -type d -name '[0-9][0-9][0-9]-*' -print0 | sort -z)
