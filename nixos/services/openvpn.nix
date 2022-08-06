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
          "3.128.0.0 255.128.0.0"
          "52.0.0.0 255.0.0.0"
          "54.0.0.0 255.0.0.0"
          "35.0.0.0 255.0.0.0"
          "63.0.0.0 255.0.0.0"
          "13.0.0.0 255.0.0.0"
        ];
      };
    };
  };
}

