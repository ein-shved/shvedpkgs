{ config, pkgs, lib, ... }:
with pkgs;
let
in {

    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        media-session.config.bluez-monitor.rules = [
        {
            # Matches all cards
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions = {
                "update-props" = {
                    "bluez5.reconnect-profiles" = [ "hfp_hf"
                                                    "hsp_hs"
                                                    "a2dp_sink" ];
                    # mSBC is not expected to work
                    # on all headset + adapter combinations.
                    "bluez5.msbc-support" = true;
                    # SBC-XQ is not expected to work
                    # on all headset + adapter combinations.
                    "bluez5.sbc-xq-support" = true;
                    "bluez5.autoswitch-profile" = true;
                };
            };
        }
        {
            matches = [
                # Matches all sources
                { "node.name" = "~bluez_input.*"; }
                # Matches all outputs
                { "node.name" = "~bluez_output.*"; }
            ];
            actions = {
                "node.pause-on-idle" = false;
            };
        }
        ];
        media-session.enable = true;
        config.pipewire = {
            "context.properties" = {
                "link.max-buffers" = 16;
                "log.level" = 2;
                "default.clock.rate" = 48000;
                "default.clock.quantum" = 32;
                "default.clock.min-quantum" = 32;
                "default.clock.max-quantum" = 32;
                "core.daemon" = true;
                "core.name" = "pipewire-0";
            };
            "context.modules" = [
            {
                name = "libpipewire-module-rtkit";
                args = {
                    "nice.level" = -15;
                    "rt.prio" = 88;
                    "rt.time.soft" = 200000;
                    "rt.time.hard" = 200000;
                };
                flags = [ "ifexists" "nofail" ];
            }
            { name = "libpipewire-module-protocol-native"; }
            { name = "libpipewire-module-profiler"; }
            { name = "libpipewire-module-metadata"; }
            { name = "libpipewire-module-spa-device-factory"; }
            { name = "libpipewire-module-spa-node-factory"; }
            { name = "libpipewire-module-client-node"; }
            { name = "libpipewire-module-client-device"; }
            {
              name = "libpipewire-module-portal";
              flags = [ "ifexists" "nofail" ];
            }
            {
              name = "libpipewire-module-access";
              args = {};
            }
            { name = "libpipewire-module-adapter"; }
            { name = "libpipewire-module-link-factory"; }
            { name = "libpipewire-module-session-manager"; }
            {
                name = "libpipewire-module-loopback";
                args = {
                    "audio.position" = [ "FL" "FR" ];
                    "capture.props" = {
                        "media.class" = "Audio/Sink";
                        "node.name" = "GeneralSink";
                        "node.description" = "Virtual Generic Sync";
                    };
                };
            }
            {
                name = "libpipewire-module-loopback";
                args = {
                    "audio.position" = [ "FL" "FR" ];
                    "capture.props" = {
                        "media.class" = "Audio/Source";
                        "node.name" = "GeneralSource";
                        "node.description" = "Virtual Generic Source";
                    };
                };
            }
            ];
        };
    };
}
