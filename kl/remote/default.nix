{ config, pkgs, ... }:
with pkgs;
let
    openconnect = callPackage .././pkgs/openconnect.nix { openssl = null; };
    klvpn = callPackage ./klvpn.nix { };
    klfs = callPackage ./klfs.nix { defaultserver="yuryshvedov.avp.ru"; };
in
{
    config = {
        environment.systemPackages = [
            pcsc-safenet
            openconnect
            gnutls
            klvpn
            klfs
        ];

        services.pcscd = {
            enable = true;
            plugins = [ pcsc-safenet ];
        };
        programs.gnupg.agent = {
            enable = true;
            pinentryFlavor = "gnome3";
        };
        environment.etc."pkcs11/modules/libeToken.module" = {
            text = "module: ${pcsc-safenet}/lib/libeToken.so";
            mode = "0644";
        };
        programs.fuse.userAllowOther = true;
        #Allow to use token bu non-root user
        security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
                if (action.id == "org.debian.pcsc-lite.access_card" &&
                    subject.user == "shved") {
                        return polkit.Result.YES;
                }
            });
            polkit.addRule(function(action, subject) {
                if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
                    subject.user == "shved") {
                        return polkit.Result.YES;
                }
            });
        '';
    };
}

