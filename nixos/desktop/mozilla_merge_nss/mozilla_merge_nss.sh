#!@shell@

set -e

cfg.parser () {
    fixed_file=$(cat $1 | sed 's/\s*=\s*/=/g') # fix ' = ' to be '='
    IFS=$'\n' && ini=( $fixed_file )           # convert to line-array
    ini=( ${ini[*]//;*/} )                     # remove comments
    ini=( ${ini[*]/#[/\}$'\n'cfg.section.} )   # set section prefix
    ini=( ${ini[*]/%]/ \(} )                   # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )                   # convert item to array
    ini=( ${ini[*]/%/ \)} )                    # close array parenthesis
    ini=( ${ini[*]/%\( \)/\(\) \{} )           # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} )                # remove extra parenthesis
    ini[0]=''                                  # remove first element
    ini[${#ini[*]} + 1]='}'                    # add the last brace
    eval "$(echo "${ini[*]}")"                 # eval the result
}

gen_profile() {
    path=$1
    user=$2

    mkdir -p "$path"
    cat > $path/profiles.ini << EOFile
[Profile0]
Name=$user
IsRelative=1
Path=$user
Default=1

[General]
StartWithLastProfile=1
Version=2

EOFile
}

get_profiles() {
    path="$1"
    prf_ini="$path/profiles.ini"
    echo $(grep '\[\S\+\]' "$prf_ini" |\
        sed 's/\[\|\]//g' | sed 's/^General$//' | sort -u)
}

get_default_profile() {
    path="$1"
    prf_ini="$path/profiles.ini"
    cfg.parser "$prf_ini"
    for prf in $(get_profiles "$path"); do
        Default=
        cfg.section.$prf
        if [ "x$Default" == "x1" ]; then
            echo "$prf"
            return 0
        fi
    done
    return 1
}

check_db() {
    path="$1"
    @certutil@ -L -d "sql:$path" 2>/dev/null >/dev/null && return 0
    return 1
}

check_db_create() {
    path="$1"

    check_db "$path" && return 0
    mkdir -p "$path" || return 1
    @certutil@ -N -d "sql:$path" --empty-password || return 1
    return 0
}

check_profiles_get_db() {
    path="$1"
    prf_ini="$path/profiles.ini"
    db_path=

    [ -d $path ] || gen_profile "$path" "$USER" >/dev/null
    profile="$(get_default_profile "$path")"
    cfg.parser "$prf_ini"
    Path=
    IsRelative=
    cfg.section.$profile
    if [ "x$IsRelative" == "x1" ]; then
        db_path="$path/$Path"
    else
        db_path="$Path"
    fi

    echo $db_path
}

check_same_files_3() {
    a="$1"
    b="$2"
    name="$3"

    [ "$a/$name" -ef "$b/$name" ] || return 1
}

db_files="cert9.db key4.db pkcs11.txt"

check_merged() {
    dst="$1"
    src="$2"

    for f in $db_files; do
        check_same_files_3 $dst $src $f || return 1
    done

    return 1
}

do_merge() {
    dst="$1"
    src="$2"

    if check_db "$src"; then
        check_merged "$dst" "$src" && return 0
        @certutil@ --merge -d "sql:$dst" --source-dir "sql:$src"

        for f in $db_files; do
            rm "$src/$f"
            ln -s "$dst/$f" "$src/$f"
        done
    else
        mkdir -p "$src"
        for f in $db_files; do
            ln -s "$dst/$f" "$src/$f"
        done
    fi
}

merge_mozilla_nss() {
    dst="$1";
    shift

    check_db_create "$dst"
    while [ -n "$1" ]; do
        profiles_dir="$1"
        shift

        mz_db="$(check_profiles_get_db $profiles_dir)"
        do_merge "$dst" "$mz_db"
    done
}
merge_mozilla_nss "$HOME/.pki/nssdb" "$HOME/.mozilla/firefox" \
                                     "$HOME/.mozilla/thunderbird"

