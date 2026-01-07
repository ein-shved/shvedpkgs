{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.hardware) needGraphic;
in
{
  config = {
    services.gnome.gnome-keyring.enable = lib.mkForce false;
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];
    time.timeZone = "Europe/Moscow";
    i18n.extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    programs.nm-applet.enable = needGraphic;
    environment.graphicPackages = with pkgs; [
      networkmanagerapplet
    ];
    home = {
      home.pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.all-themes;
        name = "Bibata-Modern-Classic";
        size = 16;
      };

      gtk = {
        enable = true;

        theme = {
          package = pkgs.all-themes;
          name = "Nordic-darker";
        };

        iconTheme = {
          package = pkgs.all-themes;
          name = "Nordic-darker";
        };

        font = {
          name = "Sans";
          size = 11;
        };

        gtk3 = {
          extraConfig = {
            gtk-application-prefer-dark-theme = 1;
          };
        };
      };
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
    };
  };
}
