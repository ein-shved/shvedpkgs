{
  config,
  options,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.services) mediaStore;
  inherit (config.hardware) isNas;
  inherit (lib) mkIf optionalAttrs optionalString;
  cfg = config.services.transmission;
  user = config.user;
  settingsDir = ".config/transmission-daemon";

in
{
  config = {
    # Sometimes we need to download Linux images from official torrents
    services.transmission = {
      enable = lib.mkDefault (
        config.home.enable && options.user.name.isDefined && !config.kl.domain.enable
      );
      user = user.name;
      home = "${user.home}";
      package = pkgs.transmission_4;
      downloadDirPermissions = "770";
      settings = {
        watch-dir = mediaStore;
        download-dir = mediaStore;
        incomplete-dir = "${mediaStore}/.incomplete";
        watch-dir-enabled = false;
      }
      // optionalAttrs (!isNas) {
        rpc-whitelist = "127.0.0.1";
        rpc-bind-address = "127.0.0.1";
      }
      // optionalAttrs isNas {
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = false;
      };
    }
    // optionalAttrs isNas {
      openFirewall = true;
      openRPCPort = true;
    };
    environment.graphicPackages = mkIf cfg.enable [
      pkgs.transmission-remote-gtk
    ];
    systemd.services.transmission = mkIf (cfg.enable && config.home.enable) {
      after = [ "home-manager-${user.name}.service" ];
    };

    user.extraGroups = mkIf cfg.enable [
      cfg.group
    ];
    system.activationScripts.transmission-daemon = mkIf (cfg.enable && config.home.enable) (
      lib.mkForce ""
    );

    hm.home.activation.transmission-daemon = mkIf cfg.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] (
        ''
          install -d -m 700 -o '${cfg.user}' -g '${cfg.group}' '${cfg.home}/${settingsDir}'
        ''
        + optionalString (cfg.downloadDirPermissions != null) ''
          install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.download-dir}'

          ${optionalString cfg.settings.incomplete-dir-enabled ''
            install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.incomplete-dir}'
          ''}
          ${optionalString cfg.settings.watch-dir-enabled ''
            install -d -m '${cfg.downloadDirPermissions}' -o '${cfg.user}' -g '${cfg.group}' '${cfg.settings.watch-dir}'
          ''}
        ''
      )
    );
  };
}
