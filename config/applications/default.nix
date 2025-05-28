{ pkgs, ... }:
{
  imports = [
    ./editors
    ./emulators
    ./misc
    ./networking
    ./version-management
    ./virtualization
  ];
  config = {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      ascii
      bash-completion
      binutils
      cifs-utils
      dconf
      dhcps
      file
      fontconfig.lib
      hunspellDicts.en-us
      hunspellDicts.ru-ru
      inotify-tools
      jq
      killall
      minicom
      nix-bash-completions
      nix-index
      nixos
      nixos-option
      pdftk
      psmisc
      screen
      sshfs
      stdmanpages
      tcpdump
      unzip
      usbutils
      wget
      zstd
    ];

    environment.graphicPackages = with pkgs; [
      cdrkit
      # TODO(Shvedov) Disabled while swiching to 25.05. Enable it back
      # drawio
      eog
      evince
      gimp
      gnome-calculator
      libreoffice
      mpv
      pinta
      playerctl
      remmina
      tdesktop
      thunderbird
      xclip
      xdotool
      yandex-music

      # Unavailable
      # discord
    ];

    environment.developmentPackages = with pkgs; [
      bear
      docker
      dowork
      gdb
      man
      man-pages
      man-pages-posix
      niv
      nix-tree
      shunit2
    ];

    programs = {
      adb.enable = true;
    };
  };
}
