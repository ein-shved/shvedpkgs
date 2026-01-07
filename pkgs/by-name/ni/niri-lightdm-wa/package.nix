{
  niri,
  makeWrapper,
  writeShellScript,
}:
let
  # Workaround for https://github.com/canonical/lightdm/issues/63
  inputWaiter = writeShellScript "inputWaiter" ''
    if [ -n "$XDG_VTNR" ] ; then
        echo "Waiting for VT $XDG_VTNR:"
        for ((i=0;i<100;i++)) ; do
          CURRENT="$(</sys/devices/virtual/tty/tty0/active)"
          echo  "  $(date +%s.%N) using $CURRENT"
          if [[ "$CURRENT" = "tty$XDG_VTNR" ]]; then
              break
          fi
          sleep 0.01
        done
    fi
  '';
in
niri.overrideAttrs (
  final: prev: {
    nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [
      makeWrapper
    ];
    postInstall = (prev.postInstall or "") + ''
      wrapProgram $out/bin/niri-session --run '${inputWaiter}'
    '';
  }
)
