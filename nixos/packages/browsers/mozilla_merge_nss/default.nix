{ stdenv,  lib, pkgs, substituteAll, nss }:
let
  ini = stdenv.mkDerivation {
    name="bash-ini-parser";
    src = ./bash-ini-parser;
    unpackPhase = ''
        true;
    '';
    buildCommand = ''
        install -Dm755 $src $out/bin/bash-ini-parser
    '';
  };
in
stdenv.mkDerivation {
    pname = "mozilla_merge_nss";
    version = "0.0.1";

    buildCommand = ''
        install -Dm755 $script $out/bin/mozilla_merge_nss
    '';

    script = substituteAll {
        src = ./mozilla_merge_nss.sh;
        isExecutable = true;
        certutil = "${nss.tools}/bin/certutil";
        modutil = "${nss.tools}/bin/modutil";
        parser = "${ini}/bin/bash-ini-parser";
        inherit (stdenv) shell;
    };

    meta = with stdenv.lib; {
        description = "Script to merge FF and TB nssdb to one with chromium";
    };
}

