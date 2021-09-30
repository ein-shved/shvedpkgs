{ pkgs, lib, config, ... }:
with pkgs;
let
  lex = pkgs.writeShellScriptBin "lex" ''
    exec ${pkgs.flex}/bin/flex "$@"
  '';
  submake = pkgs.writeShellScriptBin "submake" ''
    MKCMD="make"
    if [ ! -f ./Makefile ]; then
      n=0
      for m in ./*/Makefile; do
        if [ -f "$m" ]; then
          n="$(( $n + 1 ))";
        fi
        if [ $n -gt 1 ]; then
          break;
        fi
      done
      if [ "$n" == 1 ]; then
        MKCMD="make -f ./*/Makefile"
      fi
    fi
    echo "$MKCMD";
  '';
  nixmake = pkgs.writeShellScriptBin "nixmake" ''
    MKCMD="$(${submake}/bin/submake)"
    exec nix-shell -p cmake \
                      automake \
                      gnumake \
                      autoconf \
                      gcc \
                      ncurses \
                      pkg-config \
                      flex \
                      ncurses \
                      pkgconfig \
                      bison \
                      bc \
                      python3Packages.pip \
        --run "PATH=\$PATH:${lex}/bin $MKCMD $*"
  '';
in
{
  config = {
    nixpkgs.overlays = [
      (self: super: {
        inherit nixmake submake;
      })
    ];
    programs.bash.shellAliases = {
      make = "${nixmake}/bin/nixmake";
    };
    environment.systemPackages = [
      cmake
      automake
      gnumake
      autoconf
      gcc
      ncurses
      pkg-config
    ];
  };
}
