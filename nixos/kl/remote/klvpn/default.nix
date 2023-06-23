{ lib, pkgs, config, ... }:
let
# The procedure how to connect to kl vpn network is described globally
# so this is not a part of NDA too.
  openconnect = pkgs.callPackage ../openconnect { openssl = null; };
  p11tool = "${pkgs.gnutls}/bin/p11tool";
  grep = "${pkgs.gnugrep}/bin/grep";
  sed = "${pkgs.gnused}/bin/sed";
  cfg = config.local.kl;
  login = config.local.user.login;
  cert_chooser = pkgs.python3Packages.buildPythonApplication {
    pname = "klvpn_cert_chooser";
    version = "0.1";
    src = ./.;
  };
  klvpn = pkgs.writeShellScriptBin "klvpn" ''
    [ $UID  != 0 ] && SUDO=sudo

    url="$(${p11tool} --list-token-urls | ${grep} -m1 -o '^.*model=eToken.*$')"

    if [ -z $url ]; then
        echo "No matching token found"
        exit 1;
    fi

    url="$(${p11tool} --list-all-certs "$url" |\
           ${cert_chooser}/bin/klvpn_cert_chooser.py)"

    if [ -z $url ]; then
        echo "No matching token found"
        exit 1;
    fi

    exec $SUDO ${openconnect}/bin/openconnect --no-proxy \
        -c "$url" https://cvpn.kaspersky.com
  '';
in
{
  config = lib.mkIf cfg.remote.enable {
    nixpkgs.overlays = [ (self: super: {
      pcsc-safenet = super.callPackage ./pcsc-safenet {
          openssl = super.openssl_1_1;
        };
    }) ];
    environment.systemPackages = [
      klvpn
    ];
    services.pcscd = {
      enable = true;
      plugins = [ pkgs.pcsc-safenet ];
    };
    programs.gnupg.agent = {
      enable = true;
      pinentryFlavor = "gnome3";
    };
    environment.etc."pkcs11/modules/libeToken.module" = {
      text = "module: ${pkgs.pcsc-safenet}/lib/libeToken.so";
      mode = "0644";
    };
    programs.fuse.userAllowOther = true;
    #Allow to use token by non-root user
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_card" &&
          subject.user == "${login}") {
            return polkit.Result.YES;
        }
      });
      polkit.addRule(function(action, subject) {
        if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
          subject.user == "${login}") {
            return polkit.Result.YES;
        }
      });
    '';
    users.users."${login}".extraGroups = [
      "pkcs11"      # Can ask about secure keys
    ];
  };
}
