{ lib, config, ... }:
let
  inherit (config.services) mediaStore;
  cfg = config.services.navidrome;
  domain = "navidrome.shved.org";
in
{
  config = lib.mkIf config.hardware.isNas {
    services.navidrome = {
      enable = true;
      openFirewall = true;
      settings = {
        MusicFolder = "${mediaStore}/Music";
        EnableSharing = true;
      };
    };
    systemd.services.navidrome.serviceConfig.EnvironmentFile = config.age.secrets.lastfm-navidrome.path;
    security.acme = {
      acceptTerms = true;
      certs.${domain} = {
        email = config.user.mail;
        dnsProvider = "cloudflare";
        environmentFile = config.age.secrets.cloudflare.path;
      };
    };
    services.nginx.proxies = {
      ${domain} = {
        extraConfig = {
          forceSSL = true;
          useACMEHost = domain;
          listen = [
            {
              addr = "0.0.0.0";
              port = 8443;
              ssl = true;
            }
            {
              addr = "0.0.0.0";
              port = 443;
              ssl = true;
            }
          ];
        };
        locations."/".upstreamPort = cfg.settings.Port or 4533;
      };
      "tosec-${domain}" = {
        extraConfig = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 80;
              ssl = false;
            }
          ];
          serverName = domain;
          extraConfig = "return 301 https://$host$request_uri ;";
        };
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
    networking.firewall.allowedTCPPorts = [
      80
      443
      8443
    ]; # http & https
  };
}
