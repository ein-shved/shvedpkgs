{ stdenv, pkgs, lib, ... }:

stdenv.mkDerivation rec {
    pname = "xfce-config-shved";
    version = "0.0.1";
    src = [
        ./xfconf
    ];
    meta = {
        description = "Configuration files for xfce";
    };
    installPhase = ''
        install -d . $out/xfconf
    '';
}
