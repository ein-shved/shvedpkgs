{
  pkgs,
  config,
  lib,
  ...
}:
let
  leanVps = config.hardware.isVps && !config.hardware.isGraphic;
in
{
  config = {
    environment.systemPackages =
      with pkgs;
      [
        ascii
        bash-completion
        killall
        nixos-option
        psmisc
        screen
        tcpdump
        unzip
        wget
        zstd
      ]
      ++ lib.optionals (!leanVps) [
        binutils
        cifs-utils
        dhcps
        minicom
        sshfs
        usbutils
      ];

    environment.graphicPackages = with pkgs; [
      cdrkit
      dconf
      eog
      evince
      fontconfig.lib
      gimp
      gnome-calculator
      hunspellDicts.en-us
      hunspellDicts.ru-ru
      libreoffice
      mpv
      pdftk
      pinta
      playerctl
      remmina
      telegram-desktop
      thunderbird
      xclip
      xdotool
      feishin

      # Unavailable
      # discord
      # TODO(Shvedov) Disabled while swiching to 25.05. Enable it back
      # drawio
    ];

    environment.developmentPackages = with pkgs; [
      android-tools
      bear
      docker
      dowork
      esp-config
      file
      gdb
      gh
      inotify-tools
      jq
      man
      man-pages
      man-pages-posix
      niv
      nix-tree
      nixpkgs-review
      shunit2
      specd
      stdmanpages
    ];
  };
}
