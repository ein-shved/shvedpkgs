set -eu

printf '%s\n' "$$" > "$MOCK_DIR/pid"
printf '%s\0' "$@" > "$MOCK_DIR/argv"
pwd -P > "$MOCK_DIR/cwd"
printf '%s' "$PROBE_VALUE" > "$MOCK_DIR/env"
printf '%s' "$NIXOS_CLI_CONFIG" > "$MOCK_DIR/catalog-env"
printf '%s' "$PATH" > "$MOCK_DIR/path-env"
if [ -e flake.lock ]; then
    "$MOCK_CAT" flake.lock > "$MOCK_DIR/lock"
else
    : > "$MOCK_DIR/lock-missing"
fi

# Echo arbitrary input bytes, then add distinct markers on both output streams.
"$MOCK_CAT"
printf 'upstream stdout\n'
printf 'upstream stderr\n' >&2
if [ "$MOCK_RESULT" = signal ]; then
    kill -TERM "$$"
else
    exit "$MOCK_RESULT"
fi
