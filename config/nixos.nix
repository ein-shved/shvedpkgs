{
  imports = [
    ./.
    ./allowance.nix
    ./applications
    ./applications/editors/nixvim
    ./applications/emulators/wine
    ./applications/media/yandex-music.nix
    ./applications/misc/prusa-slicer
    ./applications/misc/translate-shell
    ./applications/networking/browsers/google-chrome
    ./applications/networking/p2p/transmission
    ./applications/version-management/git
    ./applications/virtualization/docker
    ./bashrc/bashrc.nix
    ./bashrc/inputrc.nix
    ./bashrc/starship.nix
    ./desktop
    ./desktop/anyrun
    ./desktop/kitty
    ./desktop/niri
    ./desktop/niri/niri.nix
    ./desktop/swaylock/default.nix
    ./desktop/waybar
    ./desktop/wpaperd
    ./desktop/xdg
    ./desktop/xdg/mime
    ./exceptions
    ./media
    ./media/camera
    ./media/mpv
    ./media/pipewire
    ./media/pulseaudio
    ./nix
    ./services
    ./services/home-assistant
    ./services/nas/ftp
    ./services/nas/upnp
    ./services/networking/firewall.nix
    ./services/networking/ssh.nix
    ./services/printing
    ./tools/ccache
    ./tools/security/pass
    ./tools/system/top
    ./tools/text/ripgrep

    # Disable self-written neovim configuration as it not used
    # ./applications/editors/neovim
    # Disable vim as it not used
    # ./applications/editors/vim
  ];
}
