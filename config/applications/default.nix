{ pkgs, ... }:
{
  imports = [
    ./editors
    ./emulators
    ./misc
    ./networking
    ./terminal-emulator
    ./version-management
    ./virtualization
  ];
  config = {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      ascii
      bash-completion
      bear
      binutils
      cdrkit
      cifs-utils
      dconf
      dhcps
      docker
      dowork
      drawio
      eog
      evince
      file
      fontconfig.lib
      gdb
      gimp
      gnome-calculator
      hunspellDicts.en-us
      hunspellDicts.ru-ru
      inotify-tools
      jq
      killall
      libreoffice
      man
      man-pages
      man-pages-posix
      minicom
      mpv
      nix-bash-completions
      nix-index
      nixos
      nixos-option
      pdftk
      pinta
      playerctl
      psmisc
      remmina
      screen
      shunit2
      sshfs
      stdmanpages
      tcpdump
      tdesktop
      thunderbird
      unzip
      usbutils
      wget
      xclip
      xdotool
      yandex-music
      zstd

      # Unavailable
      # discord
    ];
    programs = {
      adb.enable = true;
    };
  };
}
