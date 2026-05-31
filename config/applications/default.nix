{ pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [
      ascii
      bash-completion
      binutils
      cifs-utils
      dconf
      dhcps
      file
      inotify-tools
      jq
      killall
      minicom
      nix-bash-completions
      nixos-script
      nixos-option
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
      gdb
      gh
      man
      man-pages
      man-pages-posix
      niv
      nix-tree
      nixpkgs-review
      shunit2
    ];
  };
}
