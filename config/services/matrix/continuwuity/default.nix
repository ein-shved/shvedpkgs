{ lib, config, ... }:
let
  cfg = config.services.matrix-continuwuity;
  domain = cfg.settings.global.server_name;
in
{
  config = lib.mkIf config.hardware.isNas {
    services.matrix-continuwuity = {
      enable = true;
      settings = {
        global = {
          server_name = "matrix.shved.org";
          new_user_displayname_suffix = "";
          matrix_rtc.foci = [
            {
              type = "livekit";
              livekit_service_url = "https://livekit.shved.org";
            }
          ];
        };
      };
    };
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
        locations."/".upstreamPort = lib.elemAt cfg.settings.global.port 0;
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
    networking.firewall.allowedTCPPorts = [
      80
      443
    ]; # http & https
  };
}
