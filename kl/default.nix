{ config, pkgs, ... }:

let unstable = import <nixos-unstable> {};
    openconnect = pkgs.callPackage ./openconnect.nix { openssl = null; };
in
{
    environment.systemPackages = with pkgs; [
        unstable.pcsc-safenet
    ];

    services.pcscd = {
        enable = true;
        plugins = [ unstable.pcsc-safenet ];
    };
    programs.gnupg.agent = {
        enable = true;
        pinentryFlavor = "gnome3";
    };
}
