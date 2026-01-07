{
  symlinkJoin,
  pkgs,
}:
symlinkJoin {
  name = "AllThemes";
  paths = with pkgs; [
    bibata-cursors
    nordic
    reversal-icon-theme
    papirus-icon-theme
    zafiro-icons
    ubuntu-themes
    gnome-themes-extra
  ];
}
