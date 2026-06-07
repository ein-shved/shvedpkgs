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
      ${cfg.settings.global.server_name} = {
        extraConfig = {
          forceSSL = true;
          useACMEHost = domain;
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
