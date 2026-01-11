{
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs) klcacerts pcsc-safenet;
  klcertsBundle =
    pkgs.runCommandLocal "klcertsBundle"
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

    environment.sessionVariables = {
      CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";
    };
    hm.home.activation =
      with pkgs;
      let
        dbpath = "$HOME/.pki/nssdb";
        db = "sql:${dbpath}";
        certutil = "${nss.tools}/bin/certutil -d ${db}";
        modutil = "${nss.tools}/bin/modutil -dbdir ${db}";
      in
      {
        # The certutil may hang openning db, when pkcs11 token plugged in
        # removing it will solve this problem
        installNssDbCerts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
        installNssDbKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          echo | ${modutil} -delete eToken || true;
          echo | ${modutil} -add eToken -libfile                     \
                 ${pcsc-safenet}/lib/libeToken.so || exit 1;

          echo | ${modutil} -delete "Rutoken PKCS11" || true;
          echo | ${modutil} -add "Rutoken PKCS11" -libfile           \
                 ${rtpkcs11ecp}/lib/librtpkcs11ecp.so || exit 1;
        '';
      };
  };
}
