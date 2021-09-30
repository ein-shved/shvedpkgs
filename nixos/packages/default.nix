{ lib, config, pkgs, ... }:
{
  imports = [
    ./vim
    ./3d
    ./browsers
    ./gnupass.nix
  ];
  config = {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      evince
      tdesktop
      pinta
      gnome.eog
      gimp
      docker
      sshfs
      guake
      usbutils
      thunderbird
      gnome3.dconf
      fontconfig.lib
      bash-completion
      nix-bash-completions
      minicom
      lightlocker
      remmina
      xclip
      killall
      mpv
      man
      man-pages
      man-pages-posix
      stdmanpages
      psmisc
      ack
      unzip
      nix-index
      teamviewer
    ];
    programs = {
      adb.enable = true;
    };
    services.teamviewer.enable = true;
  };
}
