{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.navidrome;
  playlists = pkgs.runCommandLocal "SmartPlaylists" { } (
    lib.concatStrings (
      lib.mapAttrsToList (name: attrs: ''
        mkdir -p $out
        echo > $out/${name}.nsp '${builtins.toJSON attrs}'
      '') cfg.smartPlaylists
    )
  );
in
{
  options.services.navidrome.smartPlaylists = lib.mkOption {
    description = ''
      Set of smart playlists for navidrome. For details visit
      https://www.navidrome.org/docs/usage/features/smart-playlists
    '';
    type = with lib.types; attrsOf (attrsOf anything);
    default = { };
  };
  config = lib.mkIf (cfg.enable && cfg.smartPlaylists != { }) {
    services.navidrome.settings = {
      PlaylistsPath = "smartPlaylists";
    };
    systemd.services.navidrome-setupSmartPlaylists = {
      script = ''
        rm -f ${cfg.settings.MusicFolder}/smartPlaylists
        ln -sf ${playlists} ${cfg.settings.MusicFolder}/smartPlaylists
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      before = [ "navidrome.service" ];
      wantedBy = [ "navidrome.service" ];
    };
  };
}
