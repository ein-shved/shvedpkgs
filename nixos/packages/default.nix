{ lib, config, pkgs, ... }:
{
  imports = [
    ./vim
    ./3d
    ./browsers
    ./gnupass.nix
    ./translate-shell.nix
    ./guake.nix
  ];
  config = {
    nixpkgs.overlays = [
      (self: super: {
        aff4 = pkgs.callPackage ./aff4 {};
      })
    ];
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      evince
      tdesktop
      pinta
      gnome.eog
      gimp
      docker
      sshfs
      usbutils
      thunderbird
      dconf
      fontconfig.lib
      bash-completion
      nix-bash-completions
      minicom
      #lightlocker
      remmina
      xclip
      killall
      mpv
      man
      man-pages
      man-pages-posix
      stdmanpages
      psmisc
      unzip
      nix-index
      cifs-utils
      wget
      screen
      tcpdump
      zstd
      libreoffice
      gdb
      shunit2
      pdftk
      ascii
      gnome.gnome-calculator
      cdrkit
      bear
    ];
    programs = {
      adb.enable = true;
    };
  };
}
