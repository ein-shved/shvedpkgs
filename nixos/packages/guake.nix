# Fixes guake hiding withing unfocus state
{ lib, config, pkgs, ... }:
let
  dbus-send = "${pkgs.dbus}/bin/dbus-send";
  guake = pkgs.writeShellScriptBin "guake" ''
    function request() {
      ${dbus-send} --type=method_call --dest=org.guake3.RemoteControl \
        --print-reply=literal /org/guake3/RemoteControl \
        org.guake3.RemoteControl.$1
    }
    [ x"$1" != 'x-t' ] && [ x"$1" != 'x--toggle-visibility' ] && \
      exec ${pkgs.guake}/bin/guake "$@"
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
    environment.systemPackages = [
      guake
    ];
}
