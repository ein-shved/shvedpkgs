{ pkgs, config, lib, ... }:
let
  proxy = config.networking.proxy.default;
  proxied = (toString proxy) != "";
  cfg = config.services.spotify;
  spotifyd = pkgs.spotifyd.override {
    withMpris = true;
    withPulseAudio = true;
  };
  spotifydConf = pkgs.writeText "spotifyd-config" ''
      [global]
      username = "${cfg.username}"
      password = "${cfg.password}"
      use_keyring = false
      use_mpris = true
      backend = "pulseaudio"
      device_name = "nix:${config.networking.hostName}"
      bitrate = 320

      cache_path = "/home/shved/.spotify/cache"
      no_audio_cache = false

      initial_volume = "90"
      volume_normalisation = true
      normalisation_pregain = -10

      #zeroconf_port = 1234

      ${lib.optionalString proxied "proxy = \"${proxy}\""}
      device_type = "computer"
  '';
  pctr = "${pkgs.playerctl}/bin/playerctl";
  playpausespotifyd = pkgs.writeShellScriptBin "playpausespotify" ''
      ${pctr} -l | grep spotifyd &> 0 && \
        (${pctr} -p spotifyd status | grep Playing &> 0 && \
          ${pctr} -p spotifyd pause) || \
        (${pctr} -p spotifyd status | grep Paused &> 0 &&
          ${pctr} -p spotifyd play)
    '';
  playpausespotify = pkgs.writeShellScriptBin "playpausespotify" ''
    ${pkgs.dbus}/bin/dbus-send --print-reply \
                               --dest=org.mpris.MediaPlayer2.spotify \
      /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
  '';

in
{
  options = {
    services.spotify = {
      daemon = lib.mkEnableOption "Enable spotifyd";
      username = lib.mkOption {
        type = lib.types.str;
      };
      password = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.daemon {
    systemd.user.services.spotifyd = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" "sound.target" ];
        description = "spotifyd, a Spotify playing daemon";
        serviceConfig = {
          ExecStart = "${spotifyd}/bin/spotifyd --no-daemon --cache-path=\${HOME}/.cache/spotifyd --config-path=${spotifydConf}";
          Restart = "always";
          RestartSec = 12;
        };
      };
      environment.systemPackages = [ pkgs.spotify-qt playpausespotifyd ];
    })
    (lib.mkIf (!cfg.daemon) {
      environment.systemPackages = [ pkgs.spotify playpausespotify ];
    })
  ];
}
