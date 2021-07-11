{ stdenv,  lib, pkgs, substituteAll, gnutls, gnugrep, gnused }:
let
    klcerts = pkgs.callPackage .././pkgs/certificates.nix {};
    openconnect = pkgs.callPackage .././pkgs/openconnect.nix { openssl = null; };
in stdenv.mkDerivation {
    name = "klvpn";
    version = "0.0.1";
    buildInputs = [ klcerts ];

    buildCommand = ''
        install -Dm755 $script $out/bin/klvpn
    '';

    script = substituteAll {
        src = ./klvpn.sh;
        isExecutable = true;
        openconnect = "${openconnect}";
        p11tool = "${gnutls}/bin/p11tool";
        inherit (stdenv) shell;
        grep = "${gnugrep}/bin/grep";
        sed = "${gnused}/bin/sed";
    };

    meta = with stdenv.lib; {
        description = "Script which auto-connect to kl vpn";
    };
}
