{
  imports = [
    ./applications
    ./allowance.nix
    ./applications/editors/nixvim
    ./applications/media/yandex-music.nix
    ./applications/misc/translate-shell
    ./applications/networking/browsers/google-chrome
    ./applications/version-management/git
    ./bashrc/bashrc.nix
    ./bashrc/inputrc.nix
    ./bashrc/starship.nix
    ./desktop
    ./desktop/anyrun
    ./desktop/hyprland
    # ./desktop/hyprland/hypridle.nix
    # ./desktop/hyprland/hyprland.nix
    ./desktop/hyprland/hyprlock.nix
    # ./desktop/hyprland/hyprpaper.nix
    ./desktop/kitty
    ./desktop/niri
    ./desktop/niri/niri.nix
    ./desktop/waybar
    ./desktop/wpaperd
    ./desktop/xdg
    ./desktop/xdg/mime
    ./nix
    # ./tools/security/pass
    # ./tools/system/top
    ./tools/text/ripgrep
  ];
}
