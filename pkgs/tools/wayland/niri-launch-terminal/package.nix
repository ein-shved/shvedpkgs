{
  writeShellApplication,
  kitty,
  terminalPkg ? kitty,
  niri,
  jq,
}:
let
  name = terminalPkg.pname;
  cmd = "${terminalPkg}/bin/${name}";
in
writeShellApplication {
  name = "niri-launch-terminal";
  runtimeInputs = [
    niri
    jq
  ];
  /*
    This script search for terminal window in current workspace of niri
    and focuses to it. When there is no opened terminal in current workspace -
    it will be launched. If we already focused to terminal window, this script
    will try to focus back the window from which this terminal window was
    focused upon previous launch.
   */
  text = ''
    statusfile="$XDG_RUNTIME_DIR/terminal-tauncher-status.json"
    status="{}"
    if [ -f "$statusfile" ]; then
      status="$(cat "$statusfile")"
    fi

    nirimsg="niri msg --json"
    niri_focus=$($nirimsg focused-window)
    focused_workspace="$(jq -r '.["workspace_id"]' <<< "$niri_focus")"
    focused_app="$(jq -r '.["app_id"]' <<< "$niri_focus")"
    focused_id="$(jq -r '.["id"]' <<< "$niri_focus")"

    ws_status="$(jq -r ".[\"$focused_workspace\"]" <<< "$status")"

    # If we focused on terminal then try to focus back to window from which we
    # focused here
    if [ "$focused_app" == '${name}' ]; then
      if [ "$ws_status" == "null" ]; then
        exit
      fi
      from="$(jq -r '.["from"]' <<< "$ws_status")"
      to="$(jq -r '.["to"]' <<< "$ws_status")"
      # Looks like we launched terminal on previous run
      if [ "$to" == "$focused_id" ] || [ "$to" == "null" ]; then
        $nirimsg action focus-window --id "$from"
      fi
      exit
    fi

    while read -r id app_id workspace; do
      if [ "$focused_workspace" == "$workspace" ] && \
         [ "$app_id" == '${name}' ]; then
        $nirimsg action focus-window --id "$id"
        # Save windows ids for next run
        jq -r ".\"$focused_workspace\" = { \"from\" : \"$focused_id\", \"to\" : \"$id\" }" \
          <<< "$status" > "$statusfile"
        exit
      fi
    done < <($nirimsg windows |\
             jq -r '.[] | "\(.id) \(.app_id) \(.workspace_id)"')


    # We do not know id of new window, so left the 'to' field null
    jq -r ".\"$focused_workspace\" = { \"from\" : \"$focused_id\" }" \
      <<< "$status" > "$statusfile"
    exec ${cmd}
  '';
}

