{ stdenv,  lib, pkgs, substituteAll, nss }:
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
        inherit (stdenv) shell;
    };

    meta = with stdenv.lib; {
        description = "Script to merge FF and TB nssdb to one with chromium";
    };
}

