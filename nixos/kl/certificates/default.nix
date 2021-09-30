{stdenv, fetchurl, unzip, file, openssl}:

stdenv.mkDerivation {
    name = "kl-certificates";
    src = fetchurl {
        url = "https://vpnhelp.kaspersky.com/Applications/certificates.zip";
        sha256="1xd82l87d3d51dvwr5xc4wcv072b2hwzsvca7bwf28nvj7ms55vl";
    };

    nativeBuildInputs = [ unzip file openssl ];
    unpackPhase = "unzip $src";

    installPhase = ''
        for a in *.cer; do
          if file "$a" | grep -q 'PEM certificate'; then
            cp "$a" "''${a%.*}.crt"
          else
            openssl x509 -inform DER -in "$a" -out "''${a%.*}.crt"
          fi
        done;
        rm *.cer

        mkdir -p $out
        cp -r *.crt $out
    '';
    meta = {
      certsList = [
        "ExternalServicesPremiumCA.crt"
        "EXTRootCA.crt"
        "Kaspersky Root CA ECC G3.crt"
        "Kaspersky Root CA G3.crt"
        "Kaspersky Server Authentication AE CA ECC G3.crt"
        "Kaspersky Server Authentication AE CA G3.crt"
        "Kaspersky Server Authentication CA ECC G3.crt"
        "Kaspersky Server Authentication CA G3.crt"
        "Kaspersky User Authentication APAC CA G3.crt"
        "Kaspersky User Authentication CA ECC G3.crt"
        "Kaspersky User Authentication EU CA G3.crt"
        "Kaspersky User Authentication RU CA G3.crt"
        "Kaspersky User Authentication US CA G3.crt"
      ];
    };
}

