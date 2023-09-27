{ pkgs, lib, config, ... }:
let
  inherit (pkgs) klcacerts pcsc-safenet;
  klcertsBundle = pkgs.runCommandLocal
    "klcertsBundle"
    {
      inherit klcacerts;
    }
    ''
      for cert in $klcacerts/*.crt; do
        cat $cert >> $out;
      done
    '';
in
{
  config = {
    security.pki.certificateFiles = [
      "${klcertsBundle}"
    ];
    home.activations = with pkgs; let
      dbpath = "$HOME/.pki/nssdb";
      db = "sql:${dbpath}";
      certutil = "${nss.tools}/bin/certutil -d ${db}";
      modutil = "${nss.tools}/bin/modutil -dbdir ${db}";
    in
    {
      # The certutil may hang openning db, when pkcs11 token plugged in
      # removing it will solve this problem
      installNssDbCerts = ''
        if [ ! -d "${dbpath}" ]; then
            mkdir -p "${dbpath}"
            ${certutil} -N --empty-password
        fi
        for crtf in ${klcacerts}/*.crt; do
            crtn="$(basename "$crtf")"
            crtn="''${crtn::-4}"
            ${certutil} -A -t "C,," -i "$crtf" -n "$crtn"
        done
      '';
      installNssDbKeys = ''
        echo | ${modutil} -delete eToken || true;
        echo | ${modutil} -add eToken -libfile                     \
               ${pcsc-safenet}/lib/libeToken.so || exit 1;
      '';
    };
  };
}
