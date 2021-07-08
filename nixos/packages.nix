{ config, pkgs, ... }:
let
    shvedsVim = pkgs.callPackage ./../vim {};
in with pkgs;
{
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = [
        shvedsVim
        evince
#        google-chrome
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
    ];
}
