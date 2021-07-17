{ config, pkgs, ... }:

let
    unstable = import <nixos-unstable> {
                            config.allowUnfree = true;
                        };
    openconnect = pkgs.callPackage .././pkgs/openconnect.nix { openssl = null; };
    klvpn = pkgs.callPackage ./klvpn.nix { };
    klfs = pkgs.callPackage ./klfs.nix { defaultserver="yuryshvedov.avp.ru"; };
in
{
    config = {
        environment.systemPackages = with pkgs; [
            unstable.pcsc-safenet
            openconnect
            gnutls
            klvpn
            klfs
        ];

        services.pcscd = {
            enable = true;
            plugins = [ unstable.pcsc-safenet ];
        };
        programs.gnupg.agent = {
            enable = true;
            pinentryFlavor = "gnome3";
        };
        environment.etc."pkcs11/modules/libeToken.module" =  with unstable; {
            text = "module: " + pcsc-safenet.outPath + "/lib/libeToken.so";
            mode = "0644";
        };
        programs.fuse.userAllowOther = true;
    };
}

