{ config, pkgs, lib, ... }:
let
  cfg = config.user;
  homeDir = cfg.home;
  transmissionPrepare = pkgs.writeShellScript "transmissionPrepare" ''
      mkdir -p $HOME/Downloads
      mkdir -p $HOME/Downloads/.incomplete
      mkdir -p $HOME/.config/transmission-daemon
  '';
in
{
  config = lib.mkIf (!config.kl.domain.enable) {
# Sometimes we need to download Linux images from official torrents
    services.transmission = {
      enable = true;
      user = cfg.name;
      home = "${homeDir}";
      settings = {
        rpc-whitelist = "127.0.0.1";
        watch-dir = "${homeDir}/Downloads";
        download-dir = "${homeDir}/Downloads";
        incomplete-dir = "${homeDir}/Downloads/.incomplete";
        watch-dir-enabled = false;
      };
    };
    environment.systemPackages = [
      pkgs.transmission-remote-gtk
    ];
    systemd.services.transmissionPrepare = {
      description = "Workaround for transmission directories creation";
      wantedBy = [ "transmission.service" ];
      serviceConfig = {
        Type="oneshot";
        User = cfg.name;
        ExecStart = transmissionPrepare;
      };
    };
  };
}
