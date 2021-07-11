{ config, pkgs, ... }:
let
    shvedsVim = pkgs.callPackage ./../vim {};
in with pkgs;
{
    config = {
        nixpkgs.config.allowUnfree = true;
        environment.systemPackages = [
            shvedsVim
            evince
            chromium
            tdesktop
            spotify
            pinta
            gnome.eog
            gimp
            docker
            sshfs
            pass
            jetbrains-mono
            guake
            transmission-remote-gtk
            usbutils
        ];
    };
}
