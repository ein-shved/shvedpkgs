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
      cdrkit
      cifs-utils
      dconf
      dhcps
      discord
      docker
      dowork
      evince
      file
      fontconfig.lib
      gdb
      gimp
      gnome.eog
      gnome.gnome-calculator
      ide-manager
      inotify-tools
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
      yandex-music
      zstd
    ];
    programs = {
      adb.enable = true;
    };
  };
}

