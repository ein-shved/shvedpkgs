{
  fetchurl,
  unzip,
  file,
  openssl,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  name = "kl-certificates";
  src = fetchurl {
    url = "https://vpnhelp.kaspersky.com/applications/certificates.zip";
    hash = "sha256-ppgMGO1dXHrPO1XiNVld9neA8aqbE6h7lsAZ7V0G794=";
  };

  nativeBuildInputs = [
    unzip
    file
    openssl
  ];
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
