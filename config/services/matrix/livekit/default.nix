{ lib, config, ... }:
let
  lk = config.services.livekit;
  jwt = config.services.lk-jwt-service;
  domain = "livekit.shved.org";
  matrix = config.services.matrix-continuwuity;
in
{
  config = lib.mkIf matrix.enable {
    services.livekit = {
      enable = true;
      openFirewall = true;
      keyFile = config.age.secrets.livekit.path;
      settings = {
        bind_addresses = [ "" ];
        rtc = {
          use_external_ip = false;
          node_ip = "178.140.84.78";
        };
      };
    };
    services.lk-jwt-service = {
      enable = true;
      keyFile = config.age.secrets.livekit.path;
      livekitUrl = "wss://${domain}";
      port = 24634;
    };
    security.acme = {
      acceptTerms = true;
      certs.${domain} = {
        email = config.user.mail;
        dnsProvider = "cloudflare";
        environmentFile = config.age.secrets.cloudflare.path;
      };
    };
    systemd.services.lk-jwt-service.environment = {
      LIVEKIT_FULL_ACCESS_HOMESERVERS = "https://${matrix.settings.global.server_name}";
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
        locations."/".upstreamPort = lk.settings.port;
        locations."~ ^/(sfu/get|healthz|get_token)".upstreamPort = jwt.port;
      };
    };
  };
}
