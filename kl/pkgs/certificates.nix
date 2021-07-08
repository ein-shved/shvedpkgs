{stdenv, fetchurl, unzip, file}:

stdenv.mkDerivation {
    name = "kl-certificates";
    src = fetchurl {
        url = "https://vpnhelp.kaspersky.com/Applications/certificates.zip";
        sha256="1xd82l87d3d51dvwr5xc4wcv072b2hwzsvca7bwf28nvj7ms55vl";
    };

    nativeBuildInputs = [ unzip file ];
    unpackPhase = "unzip $src";

    installPhase = ''
        for a in *.cer; do [[ "''$(file "$a"|cut -d":" -f2)" = " data" ]] && openssl x509 -inform DER -in "$a" -out "''${a%.*}.crt" || cp "$a" "''${a%.*}.crt"; done; rm *.cer
        mkdir -p $out
        cp -r *.crt $out
    '';
}
