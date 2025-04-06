{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.services.transmission.settings)
    download-dir
    watch-dir
    incomplete-dir
    ;
  inherit (config.services) mediaStore;
  inherit (config.hardware) isNas;
  cfg = config.user;
  homeDir = cfg.home;
  transmissionPrepare = pkgs.writeShellScript "transmissionPrepare" ''
    mkdir -p ${download-dir}
    mkdir -p ${watch-dir}
    mkdir -p ${incomplete-dir}
  '';
in
{
  config = lib.mkIf (!config.kl.domain.enable) {
    # Sometimes we need to download Linux images from official torrents
    services.transmission =
      {
        enable = true;
        user = cfg.name;
        home = "${homeDir}";
        settings =
          {
            watch-dir = mediaStore;
            download-dir = mediaStore;
            incomplete-dir = "${mediaStore}/.incomplete";
            watch-dir-enabled = false;
          }
          // lib.optionalAttrs (!isNas) {
            rpc-whitelist = "127.0.0.1";
            rpc-bind-address = "127.0.0.1";
          }
          // lib.optionalAttrs isNas {
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist-enabled = false;
          };
      }
      // lib.optionalAttrs isNas {
        openFirewall = true;
        openRPCPort = true;
      };
    environment.graphicPackages = [
      pkgs.transmission-remote-gtk
    ];
    systemd.services.transmissionPrepare =
      lib.mkIf (!config.services.transmission.enable)
        {
          description = "Workaround for transmission directories creation";
          wantedBy = [ "transmission.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = cfg.name;
            ExecStart = transmissionPrepare;
          };
        };
  };
}
