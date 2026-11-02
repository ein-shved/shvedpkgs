# Completion is evaluated through this package's wrapper and upstream provider.
_nixos() {
    local -a response own
    mapfile -d '' -t response < <(
        NIXOS_CLI_COMPLETE=bash @nixos@ "$COMP_CWORD" "${COMP_WORDS[@]}"
    )
    COMPREPLY=()
    (( ${#response[@]} >= 2 )) || return 0
    local count=${response[1]}
    own=("${response[@]:count+2}")
    local -a COMP_WORDS=("${response[@]:2:count}")
    local COMP_CWORD=${response[0]}
    source @upstream@/share/bash-completion/completions/nixos-rebuild.bash
    _shtab_nixos_rebuild
    COMPREPLY+=("${own[@]}")
    return 0
}
complete -o filenames -F _nixos nixos
