{ config, pkgs, lib, ... }:
with pkgs;
let
    mozilla_merge_nss = callPackage ./mozilla_merge_nss {};
    # For unknown reason only this concrete binary libnssdb works.
    nss_latest = stdenv.mkDerivation {
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
in
{
  imports = [
    ./chromium
  ];
  config = {
    local.activations = {
      mergeMzNssDb = ''
        ${mozilla_merge_nss}/bin/mozilla_merge_nss
      '';
      globalTrustedCerts = {
        after ="mergeMzNssDb";
        script = ''
          ln -sf ${nss_latest}/lib64/libnssckbi.so $HOME/.pki/nssdb
        '';
      };
    };
  };
}
