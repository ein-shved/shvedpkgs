{ pkgs, lib, ... }:
with pkgs;
let
    klcerts = callPackage ./pkgs/certificates.nix {};
    hm = callPackage <home-manager/modules/lib> { };
in
{
    imports = [
        ./remote
        <home-manager/nixos>
    ];
    config = {
        security.pki.certificateFiles = [
            "${klcerts}/*.crt"
        ];
        home-manager.useGlobalPkgs = true;
        home-manager.users.shved = { pkgs, ...  }: {
            home.activation = let
                dag = hm.dag;
                db = "sql:$HOME/.pki/nssdb";
                certutil = "${nss.tools}/bin/certutil -d ${db}";
                modutil = "${nss.tools}/bin/modutil -dbdir ${db}";
            in {
                installNssDbCerts = dag.entryAfter["writeBoundary"] ''
                    for crtf in ${klcerts}/*.crt; do
                        crtn="$(basename "$crtf")"
                        crtn="''${crtn::-4}"
                        ${certutil} -A -t "C,," -i "$crtf" -n "$crtn"
                    done
                '';
                installNssDbKeys = dag.entryAfter["writeBoundary"] ''
                    echo | ${modutil} -delete eToken || true;
                    echo | ${modutil} -add eToken -libfile                     \
                           ${pcsc-safenet}/lib/libeToken.so || exit 1;
                '';
            };
        };
    };
}
