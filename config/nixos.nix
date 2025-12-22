{
  imports = [
    ./.
    ./allowance.nix
    ./applications
    # Disable self-written neovim configuration as it not used
    # ./applications/editors/neovim
    ./applications/editors/nixvim
    # Disable vim as it not used
    # ./applications/editors/vim
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
    ./desktop/anyrun
    ./desktop/hyprland
    ./desktop/hyprland/hypridle.nix
    ./desktop/hyprland/hyprland.nix
    ./desktop/hyprland/hyprlock.nix
    ./desktop/hyprland/hyprpaper.nix
    ./desktop/kitty
    ./desktop/niri
    ./desktop/niri/niri.nix
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
  ];
}
