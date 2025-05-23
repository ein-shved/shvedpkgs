{
  cntlm,
  fetchFromGitHub,
  krb5,
  ...
}:
cntlm.overrideAttrs (orig: {
  src = fetchFromGitHub {
    owner = "biserov";
    repo = "cntlm-gss";
    rev = "1a7782ac4e8dd5237b563c33685c4e48ce3e7499";
    sha256 = "kO+lYIdr2djo81OaX9z7BqzFJIdP9q3harD/CqXD+ks=";
  };
  configureFlags = [ "--enable-kerberos" ];
  buildInputs = orig.buildInputs ++ [ krb5 ];
})
