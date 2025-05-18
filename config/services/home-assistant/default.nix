{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.hardware) isNas;
  services = config.services;
in
{
  services = lib.mkIf isNas {
    home-assistant = {
      enable = true;
      # TODO: version 2024.11.1 has an issue with Zigbee integration
      package = pkgs.home-assistant;
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
          samsungtvws
          av
          go2rtc-client
          websockets
          wakeonlan
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
        "tuya"
        "zha"
      ];
      config = null;
      #config = {
      #  # Includes dependencies for a basic setup
      #  # https://www.home-assistant.io/integrations/default_config/
      #  default_config = { };
      #  frontend = { };
      #  http = { };
      #};
    };
    zigbee2mqtt = lib.mkIf isNas {
      enable = true;
      settings = {
        homeassistant = config.services.home-assistant.enable;
        permit_join = true;
        serial.port = "/dev/ttyACM0";
        mqtt.server = let
          inherit (listener) address port;
          listener = lib.elemAt services.mosquitto.listeners 0;
        in "mqtt://${address}:${toString port}";
        frontend = {
          enabled = true;
          port = 8144;
        };
        availability = {
          enabled = true;
          active.timeout = 5;
          passive.timeout = 1500;
        };
      };
    };
    mosquitto = {
      enable = true;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
          address = "127.0.0.1";
          port = 1893;
        }
      ];
    };
  };
  networking = lib.mkIf isNas {
    firewall.allowedTCPPorts = [ 8123 8144 ];
  };
}
