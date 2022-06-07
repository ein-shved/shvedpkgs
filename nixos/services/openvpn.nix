{ config, pkgs, lib, ... }:
let
  cfg = config.local.openvpn.client;
  makeRoute = address: "route ${address}\n";
  routes = lib.concatMapStrings makeRoute cfg.routes;
in
{
  config.services.openvpn.servers = lib.mkIf cfg.enable {
    "${cfg.name}" = {
      config = ''
        client
        dev tun
        proto udp
        remote ${cfg.remote}
        auth-user-pass
        ${routes}
        route-nopull
        remote-cert-tls server
        <ca>
        ${cfg.ca}
        </ca>
      '';
      authUserPass = cfg.authUserPass;
      autoStart = cfg.autoStart;
    };
  };
  options = {
    local.openvpn.client = with lib; with types; {
      enable = mkEnableOption "Enable Open VPN client";
      name = mkOption {
        type = str;
        description = "Name of client";
      };
      remote = mkOption {
        type = str;
        description = "The remote string of client config";
      };
      ca = mkOption {
        type = str;
        description = "The certificate";
      };
      authUserPass = mkOption {
        type = nullOr (submodule {
          options = {
            username = mkOption {
              type = str;
            };
            password = mkOption {
              type = str;
            };
          };
        });
        default = null;
      };
      autoStart = mkOption {
        type = bool;
        default = true;
      };
      routes = mkOption {
        type = listOf str;
        description = ''
          List of addresses to which access should be gained via vpn
        '';
        default = [
          "52.43.202.94"
          "54.200.98.62"
          "35.89.80.197"
          "54.149.9.14"

          "139.138.47.182"
          "139.138.47.183"
          "207.54.93.165"
          "207.54.93.170"

          "13.32.99.73"
          "13.32.99.91"
          "13.32.99.18"
          "13.32.99.19"

          "13.32.56.75"
          "13.32.56.83"
          "13.32.56.25"
          "13.32.56.32"

          "63.35.171.85"
          "54.194.119.148"
          "54.246.221.123"
        ];
      };
    };
  };
}

