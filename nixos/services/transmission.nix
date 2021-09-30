{ config, pkgs, ... }:
let
  cfg = config.local.user;
  homeDir = cfg.home;
in
{
  config = {
# Sometimes we need to download Linux images from official torrents
    services.transmission = {
      enable = true;
      user = cfg.login;
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
  };
}
