{ stdenv, lib, pkgs, substituteAll, gnutls, gnugrep, gnused, sudo }:
let
    openconnect = pkgs.callPackage .././pkgs/openconnect.nix { openssl = null; };
in stdenv.mkDerivation {
    pname = "klvpn";
    version = "0.0.1";
    buildInputs = [ sudo ];

    buildCommand = ''
        install -Dm755 $script $out/bin/klvpn
    '';

    script = substituteAll {
        src = ./klvpn.sh;
        isExecutable = true;
        openconnect = "${openconnect}";
        p11tool = "${gnutls}/bin/p11tool";
        grep = "${gnugrep}/bin/grep";
        sed = "${gnused}/bin/sed";
        inherit (stdenv) shell;
    };

    meta = with stdenv.lib; {
        description = "Script which auto-connect to kl vpn";
    };
}
