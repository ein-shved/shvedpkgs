{ lib, ... }:
lib.mkOverlay (
  { guake, writeShellScriptBin, dbus, ... }:
  let
    dbus-send = "${dbus}/bin/dbus-send";
    guakeWrapped = writeShellScriptBin "guake" ''
      function request() {
        ${dbus-send} --type=method_call --dest=org.guake3.RemoteControl \
          --print-reply=literal /org/guake3/RemoteControl \
          org.guake3.RemoteControl.$1
      }
      [ x"$1" != 'x-t' ] && [ x"$1" != 'x--toggle-visibility' ] && \
        exec ${guake}/bin/guake "$@"
      visible=$(request get_visibility | awk '{print $2}')
      if [ x"$visible" == 'x1' ]; then
        func="hide";
      else
        func="show";
      fi
      request $func

    '';
  in
  {
    guake = guakeWrapped;
  }
)
