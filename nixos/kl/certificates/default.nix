{stdenv, fetchurl, unzip, file, openssl}:

stdenv.mkDerivation {
    name = "kl-certificates";
    src = fetchurl {
        url = "https://vpnhelp.kaspersky.com/applications/certificates.zip";
        sha256="1ppg0rfys6f0jrxsh4wvmbqq0xznbmckbqjm7g7plp2xxlc0r656";
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
}

