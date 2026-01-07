{ config, pkgs, ... }:
{
  xdg.portal =
    let
      inherit (config.hardware) needGraphic;
    in
    {
      enable = needGraphic;
      wlr.enable = needGraphic;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.niri = {
        default = [
          "wlr"
          "gtk"
          "gnome"
        ];

        # Source: https://gitlab.archlinux.org/archlinux/packaging/packages/sway/-/commit/87acbcfcc8ea6a75e69ba7b0c976108d8e54855b
        "org.freedesktop.impl.portal.Inhibit" = "none";

        # Disable keyring
        "org.freedesktop.impl.portal.Secret" = "none";

        # wlr interfaces
        # "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        # "org.freedesktop.impl.portal.Screenshot" = "wlr";

        # gnome-keyring interfaces
        # "org.freedesktop.impl.portal.Secret" = "gnome-keyring";

        # GTK interfaces
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.AppChooser" = "gtk";
        "org.freedesktop.impl.portal.Print" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        # "org.freedesktop.impl.portal.Inhibit" = "gtk";
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.Account" = "gtk";
        "org.freedesktop.impl.portal.Email" = "gtk";
        "org.freedesktop.impl.portal.DynamicLauncher" = "gtk";
        "org.freedesktop.impl.portal.Lockdown" = "gtk";
        "org.freedesktop.impl.portal.Settings" = "gtk";
        "org.freedesktop.impl.portal.Wallpaper" = "gtk";

        # Gnome interfaces
        # "org.freedesktop.impl.portal.Access" = "gnome";
        # "org.freedesktop.impl.portal.Account" = "gnome";
        # "org.freedesktop.impl.portal.AppChooser" = "gnome";
        "org.freedesktop.impl.portal.Background" = "gnome";
        "org.freedesktop.impl.portal.Clipboard" = "gnome";
        # "org.freedesktop.impl.portal.DynamicLauncher" = "gnome";
        # "org.freedesktop.impl.portal.FileChooser" = "gnome";
        "org.freedesktop.impl.portal.InputCapture" = "gnome";
        # "org.freedesktop.impl.portal.Lockdown" = "gnome";
        # "org.freedesktop.impl.portal.Notification" = "gnome";
        # "org.freedesktop.impl.portal.Print" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        # "org.freedesktop.impl.portal.Settings" = "gnome";
        # "org.freedesktop.impl.portal.Wallpaper" = "gnome";
      };
    };
  systemd.user.services.xdg-desktop-portal-gtk = {
    after = [ "niri.service" ];
  };
}
