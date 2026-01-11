{
  config,
  pkgs,
  lib,
  ...
}:
let
  mozilla_merge_nss = pkgs.callPackage ./mozilla_merge_nss { };
  # For unknown reason only this concrete binary libnssdb works.
  nss_latest = pkgs.stdenv.mkDerivation {
    name = "libnssdbfix";
    src = ./libnssckbi.so;
    installPhase = ''
      mkdir -p "$out"/lib64;
      cp $src $out/lib64/libnssckbi.so;
    '';
    unpackPhase = ''
      true;
    '';
  };

  enable = with config.programs; (firefox.enable || chromium.enable);
in
{
  config = {
    hm.home.activation = lib.mkIf enable {
      mergeMzNssDb = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${mozilla_merge_nss}/bin/mozilla_merge_nss
      '';
      globalTrustedCerts = lib.hm.dag.entryAfter [ "mergeMzNssDb" ] ''
        ln -sf ${nss_latest}/lib64/libnssckbi.so $HOME/.pki/nssdb
      '';
    };
  };
}
