{
  config,
  lib,
  pkgs-unstable,
  ...
}:
let
  inherit (config.hardware) isNas;
in
{
  services.home-assistant = lib.mkIf isNas {
    enable = true;
    # TODO: version 2024.11.1 has an issue with Zigbee integration
    package = pkgs-unstable.home-assistant;
    extraPackages =
      python3Packages: with python3Packages; [
        brother
        getmac
        gtts
        pychromecast
        pyipp
        samsungctl
        spotifyaio
        zigpy-znp
      ];
    extraComponents = [
      "cloud"
      "dhcp"
      "esphome"
      "frontend"
      "history"
      "homeassistant"
      "http"
      "image"
      "logbook"
      "met"
      "met"
      "mobile_app"
      "mqtt"
      "onboarding"
      "person"
      "radio_browser"
      "ssdp"
      "zha"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      frontend = { };
      http = { };
    };
  };
  networking = lib.mkIf isNas {
    firewall.allowedTCPPorts = [ 8123 ];
  };
}
