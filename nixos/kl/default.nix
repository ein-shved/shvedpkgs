{ pkgs, lib, config, ... }:
let
# The kl certificates are globally available so it is not a part on NDA.
  klcerts = pkgs.callPackage ./certificates {};
  cfg = config.local.kl;
  klcertsBundle = pkgs.runCommandLocal "klcertsBundle" {
    inherit klcerts;
  } ''
    for cert in $klcerts/*.crt; do
      cat $cert >> $out;
    done
  '';
in
{
  imports = [
      ./remote
      ./domain
  ];
  options = {
    local.kl = {
      enable = lib.mkEnableOption ''
        Is current system used by Kaspersy Lab employee.
      '';
      mail = lib.mkOption {
        type = lib.types.str;
        description = "Internal KL employee e-mail.";
        default = (lib.toLower (builtins.replaceStrings [" "] ["."]
          config.local.user.name)) + "@kaspersky.com";
      };
      certs = lib.mkOption {
        type = lib.types.package;
        default = klcerts;
        description = "KL Certeficates package";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        inherit klcerts;
      })
    ];
    security.pki.certificateFiles = [
      "${klcertsBundle}"
    ];
    local.activations = with pkgs; let
      dbpath = "$HOME/.pki/nssdb";
      db = "sql:${dbpath}";
      certutil = "${nss.tools}/bin/certutil -d ${db}";
      modutil = "${nss.tools}/bin/modutil -dbdir ${db}";
    in {
    # The certutil may hang openning db, when pkcs11 token plugged in
    # removing it will solve this problem
      installNssDbCerts = ''
        if [ ! -d "${dbpath}" ]; then
            mkdir -p "${dbpath}"
            ${certutil} -N --empty-password
        fi
        for crtf in ${klcerts}/*.crt; do
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
