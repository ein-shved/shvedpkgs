{ pkgs, lib, ... }:
let
  ncproxy = pkgs: let
    nc = "${pkgs.netcat}/bin/nc";
  in pkgs.writeShellScriptBin "ncproxy" ''
    if [ $# -lt 2 ]
    then
        echo "usage: $0 <dst-host> <dst-port> [ <src-host> [ <src-port>] ]"
        exit 0
    fi

    DH="$1"; shift;
    DP="$1"; shift;
    SH="''${1-0.0.0.0}"; shift || true;
    SP="''${1-$DP}"; shift || true;

    TMP=`mktemp -d`
    PIPE=$TMP/pipe
    trap 'rm -rf "$TMP"' EXIT
    mkfifo $PIPE

    ${nc} -k -ln "$SH" "$SP" < $PIPE | ${nc} "$DH" "$DP" > $PIPE
  '';

in
{
  config = {
    nixpkgs.overlays = [(self: super: { ncproxy = ncproxy super; })];
    environment.systemPackages = [
      pkgs.ncproxy
    ];
  };
}
