{
  lib,
  xorg,
  writeShellApplication,
  gawk,
  coreutils,
  getent,
  default-user ? null,
  default-outputs ? [ ],
}:
writeShellApplication {
  name = "lightdm-single-output";
  runtimeInputs = [
    xorg.xrandr
    gawk
    coreutils
    getent
  ];
  meta.mainProgram = "lightdm-single-output";
  meta.description = ''
    The xrandr-side part of niri-single-output utility to make the X-based
    display managers works concerted with niri.
  '';
  text = ''
    home="$(getent passwd '${default-user}' | cut -d: -f6)"
    statefile="$home/.local/state/niri/last-output"
    if ! [ -f "$statefile" ]; then
      exit 0
    fi
    last="$(cat "$statefile")"
    default_outputs=(${lib.concatStringsSep " " (lib.map (n: ''"${n}"'') default-outputs)});

    if [ -z "$last" ]; then
      exit 0
    fi

    outputs="$(xrandr | awk '/ connected / {print $1}')" || exit 0

    lastConnected=0
    command="xrandr"
    for output in $outputs; do
      if [ "$output" == "$last" ]; then
        lastConnected=1
        cmd="auto"
      else
        cmd="off"
      fi
      command="$command --output $output --$cmd"
    done

    if [ "$lastConnected" == 0 ]; then
      command="xrandr"
      for output in $outputs; do
        cmd="off"
        for default in "''${default_outputs[@]}"; do
          if [ "$output" == "$default" ]; then
            lastConnected=1
            cmd="auto"
            break
          fi
        done
        command="$command --output $output --$cmd"
      done
    fi
    if [ "$lastConnected" == 0 ]; then
      exit 0;
    fi
    exec $command
  '';
}
