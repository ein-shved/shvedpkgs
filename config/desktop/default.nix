{
  config,
  pkgs,
  lib,
  ...
}:
let
  mkGraphic = lib.mkIf config.hardware.isGraphic;
in
{
  config = {
    services.gnome.gnome-keyring.enable = lib.mkDefault config.hardware.isGraphic;
    services.gnome.gcr-ssh-agent.enable = false;
    fonts.packages = mkGraphic (
      with pkgs;
      [
        jetbrains-mono
        nerd-fonts.jetbrains-mono
      ]
    );
    fonts.fontconfig.enable = config.hardware.isGraphic;
    xdg.icons.enable = config.hardware.isGraphic;
    xdg.sounds.enable = config.hardware.isGraphic;
    time.timeZone = "Europe/Moscow";
    i18n.extraLocaleSettings = {
      LC_MESSAGES = "en_US.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
    qt = mkGraphic {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };
    environment.graphicPackages = with pkgs; [
      networkmanagerapplet
    ];
    hm = mkGraphic {
      home.pointerCursor = {
        gtk.enable = true;
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
