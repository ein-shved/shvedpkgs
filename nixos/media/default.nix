{ pkgs, config, ... }:
let
in
{
  imports = [
  # Pipewire is a better option for BT audio and it is more modern, but
  # I do not use BT audio for now and pulse is more stable
  #   ./pipewire
   ./spotify
   ./mpv.nix
  ];
  config = {
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
    documentation.man.generateCaches = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };
}
