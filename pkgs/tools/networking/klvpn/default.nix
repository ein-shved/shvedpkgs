{ lib, ... }:
lib.mkOverlay (
  { python3Packages
  , writeShellApplication
  , gnutls
  , openconnect
  , ...
  }:
  rec {
    klvpn_cert_chooser = python3Packages.buildPythonApplication {
      name = "klvpn_cert_chooser";
      src = ./cert_chooser;
    };
    klvpn = writeShellApplication {
      name = "klvpn";
      runtimeInputs = [ gnutls klvpn_cert_chooser openconnect ];
      text = ''
        [ $UID  != 0 ] && SUDO=sudo

        url="$(p11tool --list-token-urls |\
             grep -m1 -o '^.*model=\(eToken\|Rutoken\).*$' || echo)"

        if [ -z "$url" ]; then
            echo "No matching token found"
            exit 1;
        fi

        url="$(p11tool --list-all-certs "$url" |\
               klvpn_cert_chooser.py)"

        if [ -z "$url" ]; then
            echo "No matching token found"
            exit 1;
        fi

        exec $SUDO openconnect --no-proxy \
            -c "$url" https://cvpn.kaspersky.com
      '';
    };
  }
)

